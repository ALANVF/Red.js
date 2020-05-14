import * as Red from "../red-types";
import RedUtil from "./util";
import RedNatives from "./natives";
import RedActions from "./actions";

export class RedFunctionCall {
	constructor(
		public func:    Red.RawAnyFunc,
		public refines: Red.RawRefinement[],
		public passed:  ExprType[]
	) {}
}

export type ExprType = Red.AnyType | RedFunctionCall;

export function stringifyRed(
	ctx:   Red.Context,
	value: ExprType
): string {
	if(value instanceof RedFunctionCall) {
		let out = value.func.name;

		if(value.refines.length > 0) {
			for(const ref of value.refines) {
				if(ref.name instanceof Red.RawInteger) {
					throw new Error("error!");
				} else {
					out += "/" + ref.name.name;
				}
			}
		}

		if(value.passed.length > 0) {
			for(const arg of value.passed) {
				out += " " + stringifyRed(ctx, arg);
			}
		}

		return out;
	} else {
		try {
			return RedActions.$$mold(ctx, value).toJsString();
		} catch(_) {
			return `${value}`;
		}
	}
}

function loadFunctionRefs(
	fn:   Red.RawAnyFunc,
	path: Red.AnyType[]
) {
	const out = new RedFunctionCall(fn, [], []);

	for(const word of path) {
		let name: Red.RawWord;
		
		if(Red.isAnyWord(word) || word instanceof Red.RawRefinement)
			name = word.word;
		else
			throw new Error(`Error at ${word}`);

		out.refines.push(new Red.RawRefinement(name));
	}

	return out;
}

function transformPath(
	ctx:  Red.Context,
	path: Red.RawPath,
	_: {
		get?: []
	} = {}
): ExprType {
	const isGet = _.get !== undefined;
	const values = path.path.slice(path.index - 1);
	const firstValue = values.shift()!;

	if(!(firstValue instanceof Red.RawWord)) {
		throw new Error(`Error at ${path}`);
	}

	let value: Red.AnyType = RedNatives.$$get(ctx, firstValue);

	while(values.length > 0) {
		if(value instanceof Red.Native || value instanceof Red.Action || value instanceof Red.RawFunction) {
			if(!isGet) {
				return loadFunctionRefs(value, values);
			} else if(isGet && values.length == 0) {
				return value;
			} else {
				throw new Error("Can't get a refined function!");
			}
		} else {
			value = RedActions.$evalPath(ctx, value, values.shift()!, new Red.RawLogic(false));
		}
	}

	return value;
}

function totalArity(func: RedFunctionCall): number {
	let nargs = func.func.arity;
	
	for(const ref of func.refines) {
		nargs += func.func.getRefine(ref).addArgs.length;
	}

	return nargs;
}

// 1 + 2 * 3 - 4 : (+ 1 (* 2 (- 3 4))) --> (- (* (+ 1 2) 3) 4)
function fixOps(expr: RedFunctionCall) {
	let e = expr;
	const ops: Red.Op[] = [];
	const args: ExprType[] = [];

	while(e instanceof RedFunctionCall && e.func instanceof Red.Op) {
		ops.push(e.func);
		args.push(e.passed[0]);

		if(e.passed[1] instanceof RedFunctionCall && e.passed[1].func instanceof Red.Op) {
			e = e.passed[1];
		} else {
			args.push(e.passed[1]);
			break;
		}
	}

	const flip = (o: Red.Op[], a: ExprType[]): RedFunctionCall => {
		if(a.length == 2 && o.length == 1) {
			return new RedFunctionCall(o[0], [], a.reverse());
		} else if(a.length < 2 || o.length < 1) {
			throw new Error("Error in binary expression!");
		} else {
			return new RedFunctionCall(o[0], [], [flip(o.slice(1), a.slice(1)), a[0]]);
		}
	};

	return flip(ops.reverse(), args.reverse());
}

// TODO: fix this for functions located inside an object!
function fnCreateTempCtx(
	ctx: Red.Context,
	fn:  Red.RawFunction
): Red.Context {
	const out = new Red.Context(ctx);
	
	for(const local of fn.locals) {
		out.addWord(local, new Red.RawUnset());
	}

	for(const arg of fn.args.map(a => a.name.word)) {
		out.addWord(arg.name, new Red.RawUnset());
	}

	for(const ref of fn.refines.map(r => r.ref.word)) {
		out.addWord(ref.name, new Red.RawNone());
	}

	return out;
}

function fnRunInCtx(
	ctx:     Red.Context,
	fn:      Red.RawFunction,
	args:    Red.AnyType[],
	refines: [Red.RawRefinement, Red.AnyType[]][]
) {
	for(let i = 0; i < args.length; i++) {
		ctx.setWord(fn.args[i].name.name, args[i]);
	}

	for(const [ref, args] of refines) {
		ctx.setWord(ref.word.name, new Red.RawLogic(true));

		for(let i = 0; i < fn.getRefine(ref).addArgs.length; i++) {
			ctx.words.push(fn.getRefine(ref).addArgs[i].name.name);
			ctx.values.push(args[i]);
		}
	}

	try {
		return RedNatives.$$do(ctx, fn.body);
	} catch(e) {
		if(e instanceof Red.CFReturn) {
			if(e.ret === undefined) {
				return new Red.RawUnset();
			} else {
				return e.ret;
			}
		} else {
			throw e;
		}
	}
}

// TODO: refinement arguments should go in the refinement option passed to the native function.
export function callNative(
	ctx:     Red.Context,
	fn:      Red.Native,
	args:    ExprType[],
	refines: Red.RawRefinement[]
) {
	const funcArity = fn.arity;
	const refArity = refines.map(r => fn.getRefine(r).addArgs.length).reduce((a1, a2) => a1 + a2, 0);
	
	if(funcArity + refArity != args.length) {
		throw new Error(`Invalid number of arguments passed to native ${fn.name}`);
	} else if(funcArity + refArity == 0) {
		return fn.func(ctx);
	} else if(funcArity == args.length) {
		args = [...args];

		// Evaluate regular arguments
		args = args.map((a, i) => {
			if(fn.args[i].name instanceof Red.RawWord) {
				return evalSingle(ctx, a);
			} else {
				return a;
			}
		});

		if(refines.length != 0) {
			const refineOptions: Record<string, any> = {};
			for(const ref of refines) {
				if(ref.name instanceof Red.RawInteger) {
					throw new Error("Functions may not have integer refinements!");
				} else {
					refineOptions[ref.name.name] = [];
				}
			}

			return fn.func(ctx, ...args, refineOptions);
		} else {
			return fn.func(ctx, ...args);
		}
	}
}

export function callAction(
	ctx:     Red.Context,
	fn:      Red.Action,
	args:    ExprType[],
	refines: Red.RawRefinement[]
) {
	const funcArity = fn.arity;
	const refArity = refines.map(r => fn.getRefine(r).addArgs.length).reduce((a1, a2) => a1 + a2, 0);
	
	if(funcArity + refArity != args.length) {
		throw new Error(`Invalid number of arguments passed to action ${fn.name}`);
	} else if(funcArity + refArity == 0) {
		return fn.func(ctx);
	} else if(funcArity == args.length) {
		args = [...args];
		
		// Evaluate regular arguments
		args = args.map((a, i) => {
			if(fn.args[i].name instanceof Red.RawWord) {
				return evalSingle(ctx, a);
			} else {
				return a;
			}
		});

		if(refines.length != 0) {
			const refineOptions: Record<string, any> = {};
			for(const ref of refines) {
				if(ref.name instanceof Red.RawInteger) {
					throw new Error("Functions may not have integer refinements!");
				} else {
					refineOptions[ref.name.name] = [];
				}
			}

			return fn.func(ctx, ...args, refineOptions);
		} else {
			return fn.func(ctx, ...args);
		}
	}
}

export function callFunction(
	ctx:     Red.Context,
	fn:      Red.RawFunction,
	args:    ExprType[],
	refines: Red.RawRefinement[]
) {
	const funcArity = fn.arity;
	const refArity = refines.map(r => fn.getRefine(r).addArgs.length).reduce((a1, a2) => a1 + a2, 0);
	
	if(funcArity + refArity != args.length) {
		throw new Error(`Invalid number of arguments passed to action ${fn.name}`);
	} else if(funcArity + refArity == 0) {
		return fnRunInCtx(fnCreateTempCtx(ctx, fn), fn, [], []);
	} else if(funcArity + refArity == args.length) {
		let fnArgs = args.slice(0, fn.arity);
		const refArgs = args.slice(fn.arity);
		
		// Evaluate regular arguments
		// TODO: lit-words should evaluate parens and get-words, and get-words shouldn't eval anything
		fnArgs = fnArgs.map((a, i) => {
			if(fn.args[i].name instanceof Red.RawWord) {
				return evalSingle(ctx, a);
			} else {
				return a;
			}
		});

		if(refArgs.length == 0) {
			return fnRunInCtx(fnCreateTempCtx(ctx, fn), fn, fnArgs, []);
		} else {
			const refOptions: [Red.RawRefinement, Red.AnyType[]][] = [];

			for(const ref of refines) {
				const getRef = fn.getRefine(ref);
				const newArgs: Red.AnyType[] = [];
				const evalArg = (arg: Red.AnyType, i: number) => {
					if(getRef.addArgs[i].name instanceof Red.RawWord) {
						return evalSingle(ctx, arg);
					} else {
						return arg;
					}
				};

				for(let i = 0; i < getRef.addArgs.length; i++) {
					newArgs.push(evalArg(refArgs.unshift(), i));
				}

				refOptions.push([ref, newArgs]);
			}

			return fnRunInCtx(fnCreateTempCtx(ctx, fn), fn, fnArgs, refOptions);
		}
	} else {
		throw new Error("error!");
	}
}

export function callOp(
	ctx:  Red.Context,
	fn:   Red.Op,
	args: [ExprType, ExprType]
): Red.AnyType {
	return callAnyFunc(ctx, fn.func, args, []);
}

export function callAnyFunc(
	ctx:     Red.Context,
	fn:      Red.RawAnyFunc,
	args:    ExprType[],
	refines: Red.RawRefinement[]
) {
	if(fn instanceof Red.Action) {
		return callAction(ctx, fn, args, refines);
	} else if(fn instanceof Red.Native) {
		return callNative(ctx, fn, args, refines);
	} else if(fn instanceof Red.RawFunction) {
		return callFunction(ctx, fn, args, refines);
	} else {
		return callOp(ctx, fn, [args[0], args[1]]);
	}
}

export function evalSingle(
	ctx:   Red.Context,
	value: ExprType
): Red.AnyType {
	// do something about quote

	if(value instanceof Red.RawPath && value.path.length == 1) {
		value = value.path[0];
	} else if(value instanceof Red.RawGetPath && value.path.length == 1) {
		value = new Red.RawGetWord(value.path[0] as Red.RawWord);
	}

	if(value instanceof Red.RawWord) {
		switch(value.name) {
			case "self": // FIX: this will break in functions nested in an object!
				return ctx;
			default:
				return RedNatives.$$get(ctx, value);
		}
	} else if(value instanceof Red.RawGetWord || value instanceof Red.RawPath || value instanceof Red.RawGetPath) {
		return RedNatives.$$get(ctx, value);
	} else if(value instanceof RedFunctionCall) {
		if(value.func instanceof Red.Native) {
			return callNative(ctx, value.func, value.passed, value.refines);
		} else if(value.func instanceof Red.Action) {
			return callAction(ctx, value.func, value.passed, value.refines);
		} else if(value.func instanceof Red.RawFunction) {
			return callFunction(ctx, value.func, value.passed, value.refines);
		} else {
			return callOp(ctx, value.func, [value.passed[0], value.passed[1]]);
		}
	} else if(value instanceof Red.RawParen) {
		return RedNatives.$$do(ctx, value);
	} else {
		return value;
	}
}

export interface GroupSingleResult {
	made:      ExprType;
	restNodes: ExprType[];
}

export function groupSingle(
	ctx:  Red.Context,
	blk:  ExprType[],
	isOp: boolean = false
): GroupSingleResult {
	let b = [...blk];
	let made: ExprType;

	checkForOp:
	if(b.length > 1 && b[1] instanceof Red.RawWord) {
		const b0 = b[0];

		if(b0 instanceof Red.RawWord) {
			const maybeFn = RedNatives.$$get(ctx, b0, {any: []});

			if(maybeFn instanceof Red.Action || maybeFn instanceof Red.Native || maybeFn instanceof Red.RawFunction) {
				if(maybeFn.arity > 0 && !(maybeFn.args[0].name instanceof Red.RawWord)) {
					break checkForOp;
				}
			}
		}

		const word = b[1] as Red.RawWord;
		const op = RedNatives.$$get(ctx, word, {any: []});
		
		if(op instanceof Red.Op) {
			// hacky thingy because idk where else to do it
			if(op.name.toLowerCase() != word.name.toLowerCase()) {
				op.name = word.name.toLowerCase();
			}

			made = b.shift()!;
			b.shift();

			let right: ExprType;

			if(op.args[1].name instanceof Red.RawWord) {
				const res = groupSingle(ctx, b, true);
				right = res.made;
				b = res.restNodes;
			}  else {
				right = b.shift()!;
			}

			if(isOp) {
				return {
					made: new RedFunctionCall(op, [], [made, right]),
					restNodes: b
				};
			} else {
				return {
					made: fixOps(new RedFunctionCall(op, [], [made, right])),
					restNodes: b
				};
			}
		}
	}

	const b0 = b.shift()!;

	if(b0 instanceof Red.RawWord) {
		made = RedNatives.$$get(ctx, b0);
	} else if(b0 instanceof Red.RawPath) {
		made = transformPath(ctx, b0);
	} else if(b0 instanceof Red.RawSetWord || b0 instanceof Red.RawSetPath) {
		made = b0;
	} else {
		return {
			made: b0,
			restNodes: b
		};
	}

	if(made instanceof RedFunctionCall) {
		const out = RedUtil.clone(made);
		const nargs = totalArity(made);
		const refs: Red.RawArgument[] = [];
		
		for(const r of made.refines) {
			refs.push(...made.func.getRefine(r).addArgs);
		}

		const args = [...made.func.args, ...refs];
		
		for(let i = 0; out.passed.length < nargs; i++) {
			const arg = args[i].name;
			
			if(arg instanceof Red.RawWord) {
				const next = groupSingle(ctx, b);
				
				if(next.made instanceof Red.RawParen) {
					next.made = RedNatives.$$do(ctx, next.made);
				}

				out.passed.push(next.made);
				b = next.restNodes;
			} else if(arg instanceof Red.RawGetWord) {
				const next = b.shift()!;
				
				if(
					next instanceof Red.RawWord || next instanceof Red.RawPath
						||
					next instanceof Red.RawGetWord || next instanceof Red.RawGetPath
				) {
					out.passed.push(RedNatives.$$get(ctx, next));
				} else {
					out.passed.push(next);
				}
			} else {
				out.passed.push(b.shift()!);
			}
		}

		return {
			made: out,
			restNodes: b
		};
	} else if(made instanceof Red.RawSetWord) {
		const out = new RedFunctionCall(RedNatives._SET, [], [made]);
		const next = groupSingle(ctx, b);

		out.passed.push(next.made);

		return {
			made: out,
			restNodes: next.restNodes
		};
	} else if(made instanceof Red.RawSetPath) {
		const value = new Red.RawPath(made.path.slice(0, -1));
		const last = made.path[made.path.length - 1];
		const out = new RedFunctionCall(RedActions.SET_PATH, [], [value, last]); // FIX: maps and contexts use put, not poke
		const next = groupSingle(ctx, b);

		out.passed.push(next.made, new Red.RawLogic(false));

		return {
			made: out,
			restNodes: next.restNodes
		};
	} else if((blk[0] instanceof Red.RawWord || blk[0] instanceof Red.RawPath) && (made instanceof Red.Action || made instanceof Red.Native || made instanceof Red.RawFunction)) {
		const out = new RedFunctionCall(made, [], []);
		const nargs = totalArity(out);

		for(let i = 0; out.passed.length < nargs; i++) {
			const arg = made.args[i].name;
			
			if(arg instanceof Red.RawWord) {
				const next = groupSingle(ctx, b);
				
				if(next.made instanceof Red.RawParen) {
					next.made = RedNatives.$$do(ctx, next.made);
				}

				out.passed.push(next.made);
				b = next.restNodes;
			} else if(arg instanceof Red.RawGetWord) {
				const next = b.shift()!;
				
				if(
					next instanceof Red.RawWord || next instanceof Red.RawPath
						||
					next instanceof Red.RawGetWord || next instanceof Red.RawGetPath
				) {
					out.passed.push(RedNatives.$$get(ctx, next));
				} else {
					out.passed.push(next);
				}
			} else {
				out.passed.push(b.shift()!);
			}
		}

		return {
			made: out,
			restNodes: b
		};
	}

	return {
		made,
		restNodes: b
	};
}