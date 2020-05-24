import * as Red from "../red-types";
import RedUtil from "./util";
import RedNatives from "./natives";
import RedActions from "./actions";

export interface Argument {
	expr:   ExprType;
	noEval: boolean;
}

export class RedFunctionCall {
	constructor(
		public func:    Red.RawAnyFunc,
		public refines: Red.RawRefinement[],
		public passed:  Argument[]
	) {}
}

export type ExprType = Red.AnyType | RedFunctionCall;

function argument(
	expr:   ExprType,
	noEval: boolean = false
): Argument {
	return {expr, noEval};
}

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
				out += " " + stringifyRed(ctx, arg.expr);
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

export function transformPath(
	ctx:   Red.Context,
	path:  Red.RawPath,
	isGet: boolean = false
): ExprType {
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
			value = RedActions.$evalPath(ctx, value, values.shift()!, Red.RawLogic.false);
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
	const args: Argument[] = [];

	while(e instanceof RedFunctionCall && e.func instanceof Red.Op) {
		ops.push(e.func);
		args.push(e.passed[0]);

		if(e.passed[1].expr instanceof RedFunctionCall && e.passed[1].expr.func instanceof Red.Op) {
			e = e.passed[1].expr;
		} else {
			args.push(e.passed[1]);
			break;
		}
	}

	const flip = (o: Red.Op[], a: Argument[]): RedFunctionCall => {
		if(a.length == 2 && o.length == 1) {
			return new RedFunctionCall(o[0], [], a.reverse());
		} else if(a.length < 2 || o.length < 1) {
			throw new Error("Error in binary expression!");
		} else {
			return new RedFunctionCall(o[0], [], [argument(flip(o.slice(1), a.slice(1))), a[0]]);
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
		out.addWord(local, Red.RawNone.none);
	}

	for(const arg of fn.args.map(a => a.name)) {
		out.addWord(arg.name, Red.RawNone.none);
	}

	for(const ref of fn.refines) {
		out.addWord(ref.ref.word.name, Red.RawLogic.false);

		for(const arg of ref.addArgs) {
			out.addWord(arg.name.name, Red.RawNone.none);
		}
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
		ctx.setWord(ref.word.name, Red.RawLogic.true);
		
		for(let i = 0; i < fn.getRefine(ref).addArgs.length; i++) {
			ctx.addWord(fn.getRefine(ref).addArgs[i].name.name, args[i]);
		}
	}

	try {
		return RedNatives.$$do(ctx, fn.body);
	} catch(e) {
		if(e instanceof Red.CFReturn) {
			if(e.ret === undefined) {
				return Red.RawUnset.unset;
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
	args:    Argument[],
	refines: Red.RawRefinement[]
) {
	const funcArity = fn.arity;
	const refArity = refines.map(r => fn.getRefine(r).addArgs.length).reduce((a1, a2) => a1 + a2, 0);
	
	if(funcArity + refArity != args.length) {
		throw new Error(`Invalid number of arguments passed to native ${fn.name}`);
	} else if(funcArity + refArity == 0) {
		return fn.func(ctx);
	} else if(funcArity == args.length) {
		// Evaluate regular arguments
		const args_ = args.map((a, i) => {
			if(fn.args[i].name instanceof Red.RawWord) {
				return evalSingle(ctx, a.expr, a.noEval);
			} else {
				return a.expr;
			}
		});

		if(refines.length != 0) {
			const refineOptions: Record<string, any> = {};

			for(const ref of refines) {
				if(ref.name instanceof Red.RawInteger) {
					throw new Error("Functions may not have integer refinements!");
				} else {
					refineOptions[ref.name.name] = []; // TODO: fix
				}
			}

			return fn.func(ctx, ...args_, refineOptions);
		} else {
			return fn.func(ctx, ...args_);
		}
	}
}

export function callAction(
	ctx:     Red.Context,
	fn:      Red.Action,
	args:    Argument[],
	refines: Red.RawRefinement[]
) {
	const funcArity = fn.arity;
	const refArity = refines.map(r => fn.getRefine(r).addArgs.length).reduce((a1, a2) => a1 + a2, 0);
	
	if(funcArity + refArity != args.length) {
		throw new Error(`Invalid number of arguments passed to action ${fn.name}`);
	} else if(funcArity + refArity == 0) {
		return fn.func(ctx);
	} else if(funcArity == args.length) {
		// Evaluate regular arguments
		const args_ = args.map((a, i) => {
			if(fn.args[i].name instanceof Red.RawWord) {
				return evalSingle(ctx, a.expr, a.noEval);
			} else {
				return a.expr;
			}
		});

		if(refines.length != 0) {
			const refineOptions: Record<string, any> = {};
			for(const ref of refines) {
				if(ref.name instanceof Red.RawInteger) {
					throw new Error("Functions may not have integer refinements!");
				} else {
					refineOptions[ref.name.name] = []; // TODO: fix
				}
			}

			return fn.func(ctx, ...args_, refineOptions);
		} else {
			return fn.func(ctx, ...args_);
		}
	}
}

export function callFunction(
	ctx:     Red.Context,
	fn:      Red.RawFunction,
	args:    Argument[],
	refines: Red.RawRefinement[]
) {
	const funcArity = fn.arity;
	const refArity = refines.map(r => fn.getRefine(r).addArgs.length).reduce((a1, a2) => a1 + a2, 0);
	
	if(funcArity + refArity != args.length) {
		throw new Error(`Invalid number of arguments passed to action ${fn.name}`);
	} else if(funcArity + refArity == 0) {
		return fnRunInCtx(fnCreateTempCtx(ctx, fn), fn, [], []);
	} else if(funcArity + refArity == args.length) {
		const funcArgs = args.slice(0, fn.arity);
		const refArgs = args.slice(fn.arity);
		
		// Evaluate regular arguments
		// TODO: lit-words should evaluate parens and get-words, and get-words shouldn't eval anything
		const fnArgs = funcArgs.map((a, i) => {
			if(fn.args[i].name instanceof Red.RawWord) {
				return evalSingle(ctx, a.expr, a.noEval);
			} else {
				return a.expr;
			}
		}) as Red.AnyType[];

		const refOptions: [Red.RawRefinement, Red.AnyType[]][] = [];

		for(const ref of refines) {
			const getRef = fn.getRefine(ref);
			const newArgs: Red.AnyType[] = [];
			const evalArg = (arg: Argument, i: number) => {
				if(getRef.addArgs[i].name instanceof Red.RawWord) {
					return evalSingle(ctx, arg.expr, arg.noEval);
				} else if(arg.expr instanceof RedFunctionCall) {
					throw new Error("error!");
				} else {
					return arg.expr;
				}
			};

			for(let i = 0; i < getRef.addArgs.length; i++) {
				newArgs.push(evalArg(refArgs.shift()!, i));
			}

			refOptions.push([ref, newArgs]);
		}

		return fnRunInCtx(fnCreateTempCtx(ctx, fn), fn, fnArgs, refOptions);
	} else {
		throw new Error("error!");
	}
}

export function callOp(
	ctx:  Red.Context,
	fn:   Red.Op,
	args: [Argument, Argument]
): Red.AnyType {
	return callAnyFunc(ctx, fn.func, args, []);
}

export function callAnyFunc(
	ctx:     Red.Context,
	fn:      Red.RawAnyFunc,
	args:    Argument[],
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
	ctx:    Red.Context,
	value:  ExprType,
	noEval: boolean
): Red.AnyType {
	/*if(value instanceof Red.RawPath && value.path.length == 1) {
		value = value.path[0];
	} else if(value instanceof Red.RawGetPath && value.path.length == 1) {
		value = new Red.RawGetWord(value.path[0] as Red.RawWord);
	}*/

	if(value instanceof RedFunctionCall) {
		if(value.func instanceof Red.Native) {
			return callNative(ctx, value.func, value.passed, value.refines);
		} else if(value.func instanceof Red.Action) {
			return callAction(ctx, value.func, value.passed, value.refines);
		} else if(value.func instanceof Red.RawFunction) {
			return callFunction(ctx, value.func, value.passed, value.refines);
		} else {
			return callOp(ctx, value.func, [value.passed[0], value.passed[1]]);
		}
	} else if(noEval) {
		return value;
	} else if(value instanceof Red.RawParen) {
		return RedNatives.$$do(ctx, value);
	} else if(value instanceof Red.RawWord || value instanceof Red.RawGetWord || value instanceof Red.RawPath || value instanceof Red.RawGetPath) {
		return RedNatives.$$get(ctx, value);
	} else {
		return value;
	}
}

export interface GroupSingleResult {
	made:      ExprType;
	restNodes: ExprType[];
	noEval:    boolean;
}

export function groupSingle(
	ctx:  Red.Context,
	blk:  ExprType[],
	isOp: boolean = false
): GroupSingleResult {
	let noEval = false;
	let b = [...blk];
	let made: ExprType;

	checkForOp:
	if(b.length > 1 && b[1] instanceof Red.RawWord) {
		const b0 = b[0]; // TODO: this needs to be correctly evaluated at some point

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
			let noEval2: boolean = false;
			
			if(op.args[1].name instanceof Red.RawWord) {
				({made: right, restNodes: b, noEval: noEval2} = groupSingle(ctx, b, true));
			} else {
				right = b.shift()!;
			}

			if(isOp) {
				return {
					made: new RedFunctionCall(op, [], [argument(made, noEval), argument(right, noEval2)]),
					restNodes: b,
					noEval: false
				};
			} else {
				return {
					made: fixOps(new RedFunctionCall(op, [], [argument(made, noEval), argument(right, noEval2)])),
					restNodes: b,
					noEval: false
				};
			}
		}
	}

	const b0 = b.shift()!;

	if(b0 instanceof Red.RawWord) {
		made = RedNatives.$$get(ctx, b0);
		noEval = true;
	} else if(b0 instanceof Red.RawPath) {
		made = transformPath(ctx, b0);
		noEval = true;
	} else if(b0 instanceof Red.RawSetWord || b0 instanceof Red.RawSetPath) {
		made = b0;
	} else if(b0 instanceof Red.RawGetWord) {
		return {
			made: RedNatives.$$get(ctx, b0),
			restNodes: b,
			noEval: true
		};
	} else if(b0 instanceof Red.RawGetPath) {
		return {
			made: transformPath(ctx, b0, true),
			restNodes: b,
			noEval: true
		};
	} else {
		return {
			made: b0,
			restNodes: b,
			noEval: false
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
				
				if(next.made instanceof Red.RawParen && !next.noEval) {
					next.made = RedNatives.$$do(ctx, next.made);
				}

				out.passed.push(argument(next.made, next.noEval));
				b = next.restNodes;
			} else if(arg instanceof Red.RawGetWord) {
				const next = b.shift()!;
				
				if(
					next instanceof Red.RawWord || next instanceof Red.RawPath
						||
					next instanceof Red.RawGetWord || next instanceof Red.RawGetPath
				) {
					out.passed.push(argument(RedNatives.$$get(ctx, next), true));
				} else {
					out.passed.push(argument(next));
				}
			} else {
				out.passed.push(argument(b.shift()!));
			}
		}
		
		return {
			made: out,
			restNodes: b,
			noEval: false
		};
	} else if(made instanceof Red.RawSetWord) {
		const out = new RedFunctionCall(RedNatives._SET, [], [argument(made, noEval)]);
		const next = groupSingle(ctx, b);

		out.passed.push(argument(next.made, next.noEval));

		return {
			made: out,
			restNodes: next.restNodes,
			noEval: false
			
		};
	} else if(made instanceof Red.RawSetPath) {
		const value = new Red.RawPath(made.path.slice(0, -1));
		const last = made.path[made.path.length - 1];
		const out = new RedFunctionCall(RedActions.SET_PATH, [], [
			argument(transformPath(ctx, value)),
			argument(last, last instanceof Red.RawWord)
		]); // FIX: this fails if the path is longer than 2 values
		const next = groupSingle(ctx, b);

		out.passed.push(argument(next.made, next.noEval), argument(Red.RawLogic.false));

		return {
			made: out,
			restNodes: next.restNodes,
			noEval: false
		};
	} else if((blk[0] instanceof Red.RawWord || blk[0] instanceof Red.RawPath) && (made instanceof Red.Action || made instanceof Red.Native || made instanceof Red.RawFunction)) {
		const out = new RedFunctionCall(made, [], []);
		const nargs = totalArity(out);

		for(let i = 0; out.passed.length < nargs; i++) {
			const arg = made.args[i].name;
			
			if(arg instanceof Red.RawWord) {
				const next = groupSingle(ctx, b);
				
				if(next.made instanceof Red.RawParen && !next.noEval) {
					next.made = RedNatives.$$do(ctx, next.made);
				}

				out.passed.push(argument(next.made, next.noEval));
				b = next.restNodes;
			} else if(arg instanceof Red.RawGetWord) {
				const next = b.shift()!;
				
				if(
					next instanceof Red.RawWord || next instanceof Red.RawPath
						||
					next instanceof Red.RawGetWord || next instanceof Red.RawGetPath
				) {
					out.passed.push(argument(RedNatives.$$get(ctx, next), true));
				} else {
					out.passed.push(argument(next));
				}
			} else {
				out.passed.push(argument(b.shift()!));
			}
		}

		return {
			made: out,
			restNodes: b,
			noEval: false
		};
	}

	return {
		made,
		restNodes: b,
		noEval
	};
}