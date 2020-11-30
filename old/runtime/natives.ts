import {tokenize} from "../tokenizer";
import {pre} from "./preprocesser";
import {system$words} from "./system";
import {transformPath, evalSingle, groupSingle, ExprType, stringifyRed} from "./eval";
import * as Red from "../red-types";
import RedActions from "./actions";
import RedMain from "../red";

function maxmin(
	ctx:   Red.Context,
	left:  Red.RawScalar|Red.RawSeries,
	right: Red.RawScalar|Red.RawSeries,
	isMax: boolean
): Red.RawScalar|Red.RawSeries {
	if(left instanceof Red.RawPair) {
		const out = new Red.RawPair(left.x, left.y);
		
		if(right instanceof Red.RawPair) {
			if(isMax) {
				if(out.x < right.x) out.x = right.x;
				if(out.y < right.y) out.y = right.y;
			} else {
				if(out.x > right.x) out.x = right.x;
				if(out.y > right.y) out.y = right.y;
			}

			return out;
		}

		else if(right instanceof Red.RawInteger || right instanceof Red.RawFloat) {
			const i = Math.floor(right.value);

			if(isMax) {
				if(out.x < i) out.x = i;
				if(out.y < i) out.y = i;
			} else {
				if(out.x > i) out.x = i;
				if(out.y > i) out.y = i;
			}

			return out;
		}
	}

	else if(left instanceof Red.RawTuple) {
		const out = new Red.RawTuple([...left.values]);
		
		if(right instanceof Red.RawTuple && left.length == right.length) {
			if(isMax) {
				for(let i = 0; i < left.length; i++) {
					if(out.values[i] < right.values[i]) out.values[i] = right.values[i];
				}
			} else {
				for(let i = 0; i < left.length; i++) {
					if(out.values[i] > right.values[i]) out.values[i] = right.values[i];
				}
			}

			return out;
		}

		else if(right instanceof Red.RawInteger || right instanceof Red.RawFloat) {
			const i = Math.floor(right.value);
			const b = i < 0 ? 0 : (i > 255 ? 255 : i);

			if(isMax) {
				for(let i = 0; i < left.length; i++) {
					if(out.values[i] < b) out.values[i] = b;
				}
			} else {
				for(let i = 0; i < left.length; i++) {
					if(out.values[i] > b) out.values[i] = b;
				}
			}

			return out;
		}
	}
	
	if(RedActions.$compare(ctx, left, right, Red.ComparisonOp.LESSER).cond == isMax) {
		return right;
	} else {
		return left;
	}
}

module RedNatives {
	export function $$print(
		ctx: Red.Context,
		val: Red.AnyType,
		_: {
			debug?: []
		} = {}
	) {
		if(_.debug !== undefined) {
			console.log(val);
		} else if(val instanceof Red.RawString) {
			console.log(val.toJsString());
		} else {
			console.log(RedActions.$$form(ctx, val).toJsString());
		}

		return Red.RawUnset.unset;
	}

	// also debugging
	export function $$prin(
		ctx: Red.Context,
		val: Red.AnyType
	) {
		if(globalThis["process"] === undefined) {
			throw new Error('Red.js native! "system/words/prin" may only be used in node.js supported environments!');
		} else {
			process.stdout.write(RedActions.$$form(ctx, val).toJsString());
			return Red.RawUnset.unset;
		}
	};

	export function $$if(
		ctx:     Red.Context,
		cond:    Red.AnyType,
		thenBlk: Red.RawBlock
	): Red.AnyType {
		if(cond.isTruthy()) {
			return $$do(ctx, thenBlk);
		} else {
			return Red.RawNone.none;
		}
	}

	export function $$unless(
		ctx:     Red.Context,
		cond:    Red.AnyType,
		thenBlk: Red.RawBlock
	): Red.AnyType {
		if(!cond.isTruthy()) {
			return $$do(ctx, thenBlk);
		} else {
			return Red.RawNone.none;
		}
	}

	export function $$either(
		ctx:     Red.Context,
		cond:    Red.AnyType,
		thenBlk: Red.RawBlock,
		elseBlk: Red.RawBlock
	): Red.AnyType {
		if(cond.isTruthy()) {
			return $$do(ctx, thenBlk);
		} else {
			return $$do(ctx, elseBlk);
		}
	}

	export function $$any(
		ctx:  Red.Context,
		cond: Red.RawBlock
	): Red.AnyType {
		let blk: ExprType[] = cond.values.slice(cond.index - 1);
		let res;

		do {
			const made = groupSingle(ctx, blk);
			res = evalSingle(ctx, made.made, made.noEval);
			blk = made.restNodes;
		} while(!res.isTruthy() && blk.length > 0);
		
		if(res.isTruthy()) {
			return res;
		} else {
			return Red.RawNone.none;
		}
	}
	
	export function $$all(
		ctx:  Red.Context,
		cond: Red.RawBlock
	): Red.AnyType {
		let blk: ExprType[] = cond.values.slice(cond.index - 1);
		let res;

		do {
			const made = groupSingle(ctx, blk);
			res = evalSingle(ctx, made.made, made.noEval);
			blk = made.restNodes;
		} while(res.isTruthy() && blk.length > 0);

		if(res.isTruthy()) {
			return res;
		} else {
			return Red.RawNone.none;
		}
	}

	export function $$while(
		ctx:  Red.Context,
		cond: Red.RawBlock,
		body: Red.RawBlock
	): Red.AnyType {
		let status = true;
		let ret;

		while(status) {
			if(!$$do(ctx, cond).isTruthy()) {
				break;
			}

			try {
				$$do(ctx, body);
			} catch(e) {
				switch(e.constructor) {
					case Red.CFBreak:
						ret = e.ret;
						status = false;
						break;
					case Red.CFContinue:
						break;
					default:
						throw(e);
				}
			}
		}

		return ret || Red.RawUnset.unset;
	}

	export function $$until(
		ctx:  Red.Context,
		body: Red.RawBlock
	): Red.AnyType {
		let status = true;
		let ret;

		while(status) {
			try {
				if(!$$do(ctx, body).isTruthy()) {
					break;
				}
			} catch(e) {
				switch(e.constructor) {
					case Red.CFBreak:
						ret = e.ret;
						status = false;
						break;
					case Red.CFContinue:
						break;
					default:
						throw(e);
				}
			}
		}

		return ret || Red.RawUnset.unset;
	}

	export function $$loop(
		ctx:   Red.Context,
		times: Red.RawInteger,
		body:  Red.RawBlock
	): Red.AnyType {
		let status = true;
		let ret;
		
		for(let i = 0; i < times.value && status; i++) {
			try {
				ret = $$do(ctx, body);
			} catch(e) {
				switch(e.constructor) {
					case Red.CFBreak:
						ret = e.ret;
						status = false;
						break;
					case Red.CFContinue:
						break;
					default:
						throw(e);
				}
			}
		}

		return ret || Red.RawUnset.unset;
	}

	export function $$repeat(
		ctx:   Red.Context,
		word:  Red.RawWord,
		value: Red.RawInteger,
		body:  Red.RawBlock
	): Red.AnyType {
		let status = true;
		let ret;

		const times = value.value;
		if(times < 0) throw new Error(`Cannot iterate ${times} times`);

		for(let i = 1; i <= times && status; i++) {
			const newCtx = new Red.Context(ctx, [
				[word.name, new Red.RawInteger(i)]
			]);
			
			try {
				ret = $$do(newCtx, body);
			} catch(e) {
				switch(e.constructor) {
					case Red.CFBreak:
						ret = e.ret;
						status = false;
						break;
					case Red.CFContinue:
						break;
					default:
						throw e;
				}
			}
		}

		return ret || Red.RawUnset.unset;
	}

	export function $$forever(
		ctx:  Red.Context,
		body: Red.RawBlock
	): Red.AnyType {
		let status = true;
		let ret;

		while(status) {
			try {
				$$do(ctx, body);
			} catch(e) {
				switch(e.constructor) {
					case Red.CFBreak:
						ret = e.ret;
						status = false;
						break;
					case Red.CFContinue:
						break;
					default:
						throw e;
				}
			}
		}

		return ret || Red.RawUnset.unset;
	}

	export function $$foreach(
		ctx:    Red.Context,
		word:   Red.RawWord|Red.RawBlock,
		series: Red.RawSeries|Red.RawMap,
		body:   Red.RawBlock
	): Red.AnyType {
		let status = true;
		let ret;
		
		const values =
			series instanceof Red.RawMap
				? (RedActions.valueSendAction("$$reflect", ctx, series, "body") as Red.RawBlock)
				: series;

		if(word instanceof Red.RawWord) {
			for(let i = values.index; i <= values.length && status; i++) {
				const newCtx = new Red.Context(ctx, [
					[word.name, RedActions.$$pick(ctx, values, new Red.RawInteger(i))]
				]);
				
				try {
					ret = $$do(newCtx, body);
				} catch(e) {
					switch(e.constructor) {
						case Red.CFBreak:
							ret = e.ret;
							status = false;
							break;
						case Red.CFContinue:
							break;
						default:
							throw e;
					}
				}
			}
		} else {
			for(const value of word.values) {
				if(!Red.isAnyWord(value)) {
					throw new TypeError(`Invalid word! \`${stringifyRed(ctx, value)}\`!`);
				}
			}
			
			const words = (word.values as Red.RawAnyWord[]).map(word => word.name);
			const skipBy = words.length;
			
			for(let i = values.index; i <= values.length && status; i += skipBy) {
				const newCtx = new Red.Context(ctx,
					words.map((word, offset) => [
						word,
						RedActions.$$pick(ctx, values, new Red.RawInteger(i + offset))
					])
				);
				
				try {
					ret = $$do(newCtx, body);
				} catch(e) {
					switch(e.constructor) {
						case Red.CFBreak:
							ret = e.ret;
							status = false;
							break;
						case Red.CFContinue:
							break;
						default:
							throw e;
					}
				}
			}
		}

		return ret || Red.RawUnset.unset;
	}

	// forall

	// remove-each

	export function $$func(
		ctx:  Red.Context,
		spec: Red.RawBlock,
		body: Red.RawBlock
	): Red.AnyType {
		return RedActions.$$make(
			ctx,
			Red.Datatypes["function!"], // TODO: provide this automatically in system.ts
			new Red.RawBlock([spec, body])
		);
	}

	/*
	function: make native! [[
			"Defines a function, making all set-words found in body, local"
			spec [block!]
			body [block!]
			/extern	"Exclude words that follow this refinement"
		]
		function
	]
	*/
	
	export function $$does(
		_ctx: Red.Context,
		body: Red.RawBlock
	): Red.AnyType {
		return new Red.RawFunction("", null, [], [], null, body);
	}
	
	export function $$has(
		ctx:  Red.Context,
		vars: Red.RawBlock,
		body: Red.RawBlock
	): Red.AnyType {
		let docSpec = null;
		
		vars = vars.current();

		if(vars.values[0] instanceof Red.RawString) {
			docSpec = vars.values[0];
			vars.values.splice(0, 1);
		}

		return RedActions.$$make(
			ctx,
			Red.Datatypes["function!"],
			new Red.RawBlock([
				new Red.RawBlock([
					...(docSpec == null ? [] : [docSpec]),
					new Red.RawRefinement(new Red.RawWord("local")),
					...vars.values
				]),
				body
			])
		);
	}

	export function $$switch( // I don't this this is how switch is supposed to work
		ctx:   Red.Context,
		value: Red.AnyType,
		cases: Red.RawBlock,
		_: {
			all?:     [],
			strict?:  [],
			default?: [Red.RawBlock]
		} = {}
	): Red.AnyType {
		const isAll = _.all !== undefined;
		let ret;
		let _cases: ExprType[] = cases.values.slice(cases.index-1);
		const comp = _.strict !== undefined ? $$strict_equal_q : $$equal_q;
		
		while(_cases.length != 0) {
			let next = groupSingle(ctx, _cases);
			const matchExpr = evalSingle(ctx, next.made, next.noEval);
			
			_cases = next.restNodes;
			next = groupSingle(ctx, _cases);
			_cases = next.restNodes;

			const matchBlock = evalSingle(ctx, next.made, next.noEval);

			if(!(matchBlock instanceof Red.RawBlock)) {
				throw new TypeError("Expected block! but got " + Red.typeName(matchBlock));
			}

			if(comp(ctx, value, matchExpr).cond) {
				ret = $$do(ctx, matchBlock);
				if(!isAll) break;
			}
		}

		if(ret == null && _.default !== undefined && _.default[0] != null) {
			ret = $$do(ctx, _.default[0]);
		}

		return ret || Red.RawNone.none;
	}
	
	export function $$case(
		ctx:   Red.Context,
		cases: Red.RawBlock,
		_: {
			all?: []
		} = {}
	): Red.AnyType {
		const isAll = _.all !== undefined;
		let ret;
		let _cases: ExprType[] = cases.values.slice(cases.index-1);
		
		while(_cases.length != 0) {
			let next = groupSingle(ctx, _cases);
			const matchExpr = evalSingle(ctx, next.made, next.noEval);
			
			_cases = next.restNodes;
			next = groupSingle(ctx, _cases);
			_cases = next.restNodes;

			const matchBlock = evalSingle(ctx, next.made, next.noEval);

			if(matchBlock instanceof Red.RawBlock) {
				if(matchExpr.isTruthy()) {
					ret = $$do(ctx, matchBlock);
					if(!isAll) break;
				}
			} else {
				if(matchExpr.isTruthy()) {
					ret = evalSingle(ctx, matchBlock, false);
					if(!isAll) break;
				}
			}
		}

		return ret || Red.RawNone.none;
	}

	/*
	do: make native! [[
			"Evaluates a value, returning the last evaluation result"
			value [any-type!]
			/expand "Expand directives before evaluation"
			/args "If value is a script, this will set its system/script/args"
				arg "Args passed to a script (normally a string)"
			/next "Do next expression only, return it, update block word"
				position [word!] "Word updated with new block position"
		]
		#get-definition NAT_DO
	]
	*/
	export function $$do(
		ctx:   Red.Context,
		value: Red.AnyType,
		_: {
			expand?: [],
			args?:   [Red.AnyType],
			next?:   [Red.RawLitWord]
		} = {}
	): Red.AnyType {
		if(Red.isAnyWord(value)) {
			return $$get(ctx, value);
		} else if(Red.isAnyPath(value)) {
			return evalSingle(ctx, transformPath(ctx, value, value instanceof Red.RawGetPath), true);
		} else if(value instanceof Red.RawBlock) {
			let val = value.current();

			if(_.expand !== undefined)
				val = pre(ctx, val);
			
			if(_.next !== undefined) {
				Red.todo();
			} else {
				if(val.values.length == 0) {
					return Red.RawUnset.unset;
				}
				
				let last: Red.AnyType = Red.RawUnset.unset;
				let blk: ExprType[] = val.values;

				while(blk.length > 0) {
					const grouped = groupSingle(ctx, blk);
					last = evalSingle(ctx, grouped.made, grouped.noEval);
					blk = grouped.restNodes;
				}
				
				return last;
			}
		} else if(value instanceof Red.RawParen) {
			let val = value.current();
			
			if(_.next !== undefined) {
				Red.todo();
			} else {
				if(val.values.length == 0) {
					return Red.RawUnset.unset;
				}
				
				let last: Red.AnyType = Red.RawUnset.unset;
				let blk: ExprType[] = val.values;

				while(blk.length > 0) {
					const grouped = groupSingle(ctx, blk);
					last = evalSingle(ctx, grouped.made, grouped.noEval);
					blk = grouped.restNodes;
				}
				
				return last;
			}
		} else if(value instanceof Red.RawFile) {
			return RedMain.evalFile(value.name.ref, undefined, ctx);
		} else if(value instanceof Red.RawString) {
			let out = new Red.RawBlock(tokenize(value.current().toJsString()));
			//if(doExpand) out = pre(ctx, out);

			return $$do(ctx, out, _);
		} else if(value instanceof Red.RawUrl) {
			Red.todo();
		} else {
			return value;
		}
	}

	// ...
	
	export function $$reduce(
		ctx:   Red.Context,
		value: Red.AnyType,
		_: {
			into?: [Red.RawAnyBlock]
		} = {}
	) {
		const made = [];

		if(value instanceof Red.RawBlock) {
			let blk: ExprType[] = value.values.slice(value.index-1);

			while(blk.length > 0) {
				const res = groupSingle(ctx, blk);
				made.push(evalSingle(ctx, res.made, res.noEval));
				blk = res.restNodes;
			}
		} else {
			made.push(value);
		}

		if(_.into === undefined) {
			if(value instanceof Red.RawBlock) {
				return new Red.RawBlock(made);
			} else {
				return made[0];
			}
		} else {
			const [out] = _.into;
			if(out instanceof Red.RawBlock) {
				out.values.splice(out.index-1, 0, ...made);
				return out;
			} else {
				Red.todo();
			}
		}
	}

	/*
	compose: make native! [[
			"Returns a copy of a block, evaluating only parens"
			value [block!]
			/deep "Compose nested blocks"
			/only "Compose nested blocks as blocks containing their values"
			/into "Put results in out block, instead of creating a new block"
				out [any-block!] "Target block for results, when /into is used"
		]
		#get-definition NAT_COMPOSE
	]
	*/
	export function $$compose(
		ctx:   Red.Context,
		value: Red.RawBlock,
		_: {
			deep?: [],
			only?: [],
			into?: [Red.RawAnyBlock]
		} = {}
	): Red.RawBlock {
		const blk = value.values.slice(value.index - 1);
		
		if(_.into !== undefined) {
			Red.todo();
		}

		blk.forEach((e, i) => {
			if(e instanceof Red.RawParen) {
				const res = evalSingle(ctx, e, false);

				if(res instanceof Red.RawBlock && _.only !== undefined) {
					blk.splice(i, 1, ...res.values.slice(res.index-1));
				} else {
					blk[i] = res;
				}
			} else if(e instanceof Red.RawBlock && _.deep !== undefined) {
				blk[i] = $$compose(ctx, e, _);
			}
		});

		return new Red.RawBlock(blk);
	}

	/*
	get: make native! [[
			"Returns the value a word refers to"
			word	[any-word! refinement! path! object!]
			/any  "If word has no value, return UNSET rather than causing an error"
			/case "Use case-sensitive comparison (path only)"
			return: [any-type!]
		] 
		#get-definition NAT_GET
	]
	*/
	// this needs some cleaning up
	export function $$get(
		ctx:  Red.Context,
		value: Red.RawAnyWord|Red.RawRefinement|Red.RawPath|Red.RawObject,
		_: {
			any?:  [],
			case?: []
		} = {}
	): Red.AnyType {
		const isCase = _.case !== undefined;
		const isAny = _.any !== undefined;
		let name: string;

		if(Red.isAnyWord(value)) {
			name = value.name;
		} else {
			Red.todo();
		}

		const fres = ctx.hasWord(name, isCase, true);
		const fresSW = system$words.hasWord(name, isCase);
		const fresG = Red.Context.$.hasWord(name, isCase);

		if(fres) {
			const res = ctx.getWord(name, isCase, true);

			if(!(res instanceof Red.RawUnset && !isAny)) {
				return res;
			} 
		} else if(fresSW) {
			const resSW = system$words.getWord(name, isCase);
			
			if(!(resSW instanceof Red.RawUnset && !isAny)) {
				return resSW;
			}
		} else if(fresG) {
			const resG = Red.Context.$.getWord(name, isCase);
			
			if(!(resG instanceof Red.RawUnset && !isAny)) {
				return resG;
			}
		}

		if(isAny) {
			return Red.RawUnset.unset;
		} else {
			throw new Error(`${name} has no value!`);
		}
	}

	/*
	set: make native! [[
			"Sets the value(s) one or more words refer to"
			word	[any-word! block! object! path!] "Word, object, map path or block of words to set"
			value	[any-type!] "Value or block of values to assign to words"
			/any  "Allow UNSET as a value rather than causing an error"
			/case "Use case-sensitive comparison (path only)"
			/only "Block or object value argument is set as a single value"
			/some "None values in a block or object value argument, are not set"
			return: [any-type!]
		]
		#get-definition NAT_SET
	]
	*/
	// this probably needs some work as well
	export function $$set(
		ctx:      Red.Context,
		value:    Red.RawAnyWord|Red.RawPath|Red.RawBlock|Red.RawObject,
		newValue: Red.AnyType,
		_: {
			any?:  [],
			case?: [],
			only?: [],
			some?: []
		} = {}
	): Red.AnyType {
		const isCase = _.case !== undefined;
		let word: string;
		
		if(Red.isAnyWord(value)) {
			word = value.name;
		} else {
			return Red.todo();
		}
		
		// TODO: fix the actual `addWord` method for contexts
		//ctx.addWord(word, newValue, isCase, true);
		if(ctx.hasWord(word, isCase)) {
			ctx.setWord(word, newValue, isCase);
		} else if(ctx.outer !== undefined) {
			$$set(ctx.outer, value, newValue, _);
		} else {
			ctx.addWord(word, newValue, isCase);
		}
		
		return newValue;
	}

	export function $$equal_q(
		ctx:    Red.Context,
		value1: Red.AnyType,
		value2: Red.AnyType
	): Red.RawLogic {
		return RedActions.$compare(ctx, value1, value2, Red.ComparisonOp.EQUAL);
	}
	export function $$not_equal_q(
		ctx:    Red.Context,
		value1: Red.AnyType,
		value2: Red.AnyType
	): Red.RawLogic {
		return RedActions.$compare(ctx, value1, value2, Red.ComparisonOp.NOT_EQUAL);
	}
	export function $$strict_equal_q(
		ctx:    Red.Context,
		value1: Red.AnyType,
		value2: Red.AnyType
	): Red.RawLogic {
		return RedActions.$compare(ctx, value1, value2, Red.ComparisonOp.STRICT_EQUAL);
	}
	export function $$lesser_q(
		ctx:    Red.Context,
		value1: Red.AnyType,
		value2: Red.AnyType
	): Red.RawLogic {
		return RedActions.$compare(ctx, value1, value2, Red.ComparisonOp.LESSER);
	}
	export function $$greater_q(
		ctx:    Red.Context,
		value1: Red.AnyType,
		value2: Red.AnyType
	): Red.RawLogic {
		return RedActions.$compare(ctx, value1, value2, Red.ComparisonOp.GREATER);
	}
	export function $$lesser_or_equal_q(
		ctx:    Red.Context,
		value1: Red.AnyType,
		value2: Red.AnyType
	): Red.RawLogic {
		return RedActions.$compare(ctx, value1, value2, Red.ComparisonOp.LESSER_EQUAL);
	}
	export function $$greater_or_equal_q(
		ctx:    Red.Context,
		value1: Red.AnyType,
		value2: Red.AnyType
	): Red.RawLogic {
		return RedActions.$compare(ctx, value1, value2, Red.ComparisonOp.GREATER_EQUAL);
	}
	export function $$same_q(
		ctx:    Red.Context,
		value1: Red.AnyType,
		value2: Red.AnyType
	): Red.RawLogic {
		return RedActions.$compare(ctx, value1, value2, Red.ComparisonOp.SAME);
	}

	export function $$not(
		_ctx:  Red.Context,
		value: Red.AnyType
	): Red.RawLogic {
		return Red.RawLogic.from(!value.isTruthy());
	}
	
	export function $$type_q(
		_ctx:  Red.Context,
		value: Red.AnyType,
		_: {
			word?: []
		} = {}
	): Red.AnyType {
		if(_.word === undefined) {
			return system$words.getWord(Red.typeName(value));
		} else {
			return new Red.RawWord(Red.typeName(value));
		}
	}

	/* I don't like this function. too magical
	bind: make native! [[
			"Bind words to a context; returns rebound words"
			word 	[block! any-word!]
			context [any-word! any-object! function!]
			/copy	"Deep copy blocks before binding"
			return: [block! any-word!]
		]
		#get-definition NAT_BIND
	]
	*/

	/* same here
	in: make native! [[
			"Returns the given word bound to the object's context"
			object [any-object!]
			word   [any-word!]
		]
		#get-definition NAT_IN
	]
	*/

	// ...

	/*
	union: make native! [[
			"Returns the union of two data sets"
			set1 [block! hash! string! bitset! typeset!]
			set2 [block! hash! string! bitset! typeset!]
			/case "Use case-sensitive comparison"
			/skip "Treat the series as fixed size records"
				size [integer!]
			return: [block! hash! string! bitset! typeset!]
		]
		union
	]
	*/
	export function $$union(
		ctx:  Red.Context,
		set1: Red.RawBlock|Red.RawHash|Red.RawString|Red.RawBitset|Red.RawTypeset,
		set2: typeof set1,
		_: {
			case?: []
			skip?: [Red.RawInteger]
		} = {}
	): typeof set1 {
		if(_.case !== undefined || _.skip !== undefined) Red.todo();

		if(set1 instanceof Red.RawBlock && set2 instanceof Red.RawBlock) {
			Red.todo();
		} else if(set1 instanceof Red.RawHash && set2 instanceof Red.RawHash) {
			Red.todo();
		} else if(set1 instanceof Red.RawString && set2 instanceof Red.RawString) {
			Red.todo();
		} else if((set1 instanceof Red.RawBitset && set2 instanceof Red.RawBitset) || (set1 instanceof Red.RawTypeset && set2 instanceof Red.RawTypeset)) {
			return RedActions.$$or_t(ctx, set1, set2) as typeof set1;
		} else {
			throw new TypeError(`Expected ${Red.typeName(set1)} not ${Red.typeName(set2)}`);
		}
	}

	// ...
	
	export function $$negative_q(
		_ctx: Red.Context,
		num:  Red.RawNumber|Red.RawTime
	): Red.RawLogic {
		if(num instanceof Red.RawInteger || num instanceof Red.RawFloat || num instanceof Red.RawPercent) {
			return Red.RawLogic.from(num.value < 0);
		} else if(num instanceof Red.RawMoney) {
			return Red.RawLogic.from(num.value < 0);
		} else {
			return Red.RawLogic.from(num.toNumber() < 0);
		}
	}

	export function $$positive_q(
		_ctx: Red.Context,
		num:  Red.RawNumber|Red.RawTime
	): Red.RawLogic {
		if(num instanceof Red.RawInteger || num instanceof Red.RawFloat || num instanceof Red.RawPercent) {
			return Red.RawLogic.from(num.value > 0);
		} else if(num instanceof Red.RawMoney) {
			return Red.RawLogic.from(num.value > 0);
		} else {
			return Red.RawLogic.from(num.toNumber() > 0);
		}
	}
	
	export function $$max(
		ctx:   Red.Context,
		left:  Red.RawScalar|Red.RawSeries,
		right: Red.RawScalar|Red.RawSeries
	): Red.RawScalar|Red.RawSeries {
		return maxmin(ctx, left, right, true);
	}
	
	export function $$min(
		ctx:   Red.Context,
		left:  Red.RawScalar|Red.RawSeries,
		right: Red.RawScalar|Red.RawSeries
	): Red.RawScalar|Red.RawSeries {
		return maxmin(ctx, left, right, false);
	}
	
	export function $$shift(
		_ctx: Red.Context,
		int:  Red.RawInteger,
		bits: Red.RawInteger,
		_: {
			left?:    [],
			logical?: []
		} = {}
	): Red.RawInteger {
		if(_.left !== undefined) {
			return new Red.RawInteger(int.value << bits.value);
		} else if(_.logical !== undefined) {
			return new Red.RawInteger(int.value >>> bits.value);
		} else {
			return new Red.RawInteger(int.value >> bits.value);
		}
	}
	
	// ...
	
	export function $$sine(
		_ctx:  Red.Context,
		angle: Red.RawNumber,
		_: {
			radians?: []
		} = {}
	): Red.RawFloat {
		if(_.radians === undefined) {
			return new Red.RawFloat(Math.sin(angle.value * Math.PI / 180));
		} else {
			return new Red.RawFloat(Math.sin(angle.value));
		}
	}
	
	export function $$cosine(
		_ctx:  Red.Context,
		angle: Red.RawNumber,
		_: {
			radians?: []
		} = {}
	): Red.RawFloat {
		if(_.radians === undefined) {
			return new Red.RawFloat(Math.cos(angle.value * Math.PI / 180));
		} else {
			return new Red.RawFloat(Math.cos(angle.value));
		}
	}
	
	export function $$tangent(
		_ctx:  Red.Context,
		angle: Red.RawNumber,
		_: {
			radians?: []
		} = {}
	): Red.RawFloat {
		if(_.radians === undefined) {
			return new Red.RawFloat(Math.tan(angle.value * Math.PI / 180));
		} else {
			return new Red.RawFloat(Math.tan(angle.value));
		}
	}
	
	export function $$arcsine(
		_ctx:  Red.Context,
		value: Red.RawNumber,
		_: {
			radians?: []
		} = {}
	): Red.RawFloat {
		if(_.radians === undefined) {
			return new Red.RawFloat(Math.asin(value.value) * 180 / Math.PI);
		} else {
			return new Red.RawFloat(Math.asin(value.value));
		}
	}
	
	export function $$arccosine(
		_ctx:  Red.Context,
		value: Red.RawNumber,
		_: {
			radians?: []
		} = {}
	): Red.RawFloat {
		if(_.radians === undefined) {
			return new Red.RawFloat(Math.acos(value.value) * 180 / Math.PI);
		} else {
			return new Red.RawFloat(Math.acos(value.value));
		}
	}
	
	export function $$arctangent(
		_ctx:  Red.Context,
		value: Red.RawNumber,
		_: {
			radians?: []
		} = {}
	): Red.RawFloat {
		if(_.radians === undefined) {
			return new Red.RawFloat(Math.atan(value.value) * 180 / Math.PI);
		} else {
			return new Red.RawFloat(Math.atan(value.value));
		}
	}
	
	export function $$arctangent2(
		_ctx: Red.Context,
		y:    Red.RawNumber,
		x:    Red.RawNumber,
		_: {
			radians?: []
		} = {}
	): Red.RawFloat {
		if(_.radians === undefined) {
			return new Red.RawFloat(Math.atan2(y.value, x.value) * 180 / Math.PI);
		} else {
			return new Red.RawFloat(Math.atan2(y.value, x.value));
		}
	}
	
	export function $$nan_q(
		_ctx:  Red.Context,
		value: Red.RawNumber
	): Red.RawLogic {
		return Red.RawLogic.from(isNaN(value.value));
	}
	
	export function $$zero_q(
		_ctx:  Red.Context,
		value: Red.RawNumber|Red.RawPair|Red.RawTime|Red.RawChar|Red.RawTuple
	): Red.RawLogic {
		if(Red.isNumber(value)) {
			return Red.RawLogic.from(value.value == 0);
		} else if(value instanceof Red.RawPair) {
			return Red.RawLogic.from(value.x == 0 && value.y == 0);
		} else if(value instanceof Red.RawTime) {
			return Red.RawLogic.from(value.seconds == 0 && value.minutes == 0 && value.hours == 0);
		} else if(value instanceof Red.RawChar) {
			return Red.RawLogic.from(value.char == 0);
		} else {
			return Red.RawLogic.from(value.values.every(n => n == 0));
		}
	}
	
	export function $$log_2(
		_ctx:  Red.Context,
		value: Red.RawNumber
	): Red.RawFloat {
		return new Red.RawFloat(Math.log2(value.value));
	}
	
	export function $$log_10(
		_ctx:  Red.Context,
		value: Red.RawNumber
	): Red.RawFloat {
		return new Red.RawFloat(Math.log10(value.value));
	}
	
	export function $$log_e(
		_ctx:  Red.Context,
		value: Red.RawNumber
	): Red.RawFloat {
		return new Red.RawFloat(Math.log(value.value));
	}
	
	export function $$exp(
		_ctx:  Red.Context,
		value: Red.RawNumber
	): Red.RawFloat {
		return new Red.RawFloat(Math.exp(value.value));
	}
	
	export function $$square_root(
		_ctx:  Red.Context,
		value: Red.RawNumber
	): Red.RawFloat {
		return new Red.RawFloat(Math.sqrt(value.value));
	}

	// ...

	export function $$value_q(
		ctx:   Red.Context,
		value: Red.AnyType
	): Red.RawLogic {
		if(Red.isAnyWord(value)) {
			value = $$get(ctx, value, {any: []});
		}

		return Red.RawLogic.from(value != Red.RawUnset.unset);
	}
	
	export function $$break(
		_ctx: Red.Context,
		_: {
			return?: [Red.AnyType]
		} = {}
	): never {
		throw new Red.CFBreak(_.return ?  _.return[0] : undefined);
	}
	export function $$continue(
		_ctx: Red.Context
	): never {
		throw new Red.CFContinue();
	}
	export function $$exit(
		_ctx: Red.Context
	): never {
		throw new Red.CFReturn();
	}
	export function $$return(
		_ctx:  Red.Context,
		value: Red.AnyType
	): never {
		throw new Red.CFReturn(value);
	}

	// ...

	export function $$unset(
		ctx:  Red.Context,
		word: Red.RawAnyWord|Red.RawBlock
	): Red.RawUnset {
		if(Red.isAnyWord(word)) {
			if(ctx.hasWord(word.name, false, true)) {
				ctx.setWord(word.name, Red.RawUnset.unset, false, true);
			}
		} else {
			for(const w of word.current().values) {
				if(Red.isAnyWord(w) && ctx.hasWord(w.name, false, true)) {
					ctx.setWord(w.name, Red.RawUnset.unset, false, true);
				}
			}
		}

		return Red.RawUnset.unset;
	}


	// ... Rebol-specific stuff I might add

	/*
	apply: native [
		"Apply a function to a reduced block of arguments."
		fn    [any-function!] "Function value to apply"
		block [block!]        "Block of args, reduced first (unless /only)"
		/only                 "Use arg values as-is, do not reduce the block"
	]

	map-each: native [
		{Evaluates a block for each value(s) in a series and returns them as a block.}
		'word [word! block!]  "Word or block of words to set each time (local)"
		data [block! vector!] "The series to traverse"
		body [block!]         "Block to evaluate each time"
	]

	++: native [
		{Increment an integer or series index. Return its prior value.}
		'word [word!] "Integer or series variable"
	]

	--: native [
		{Decrement an integer or series index. Return its prior value.}
		'word [word!] "Integer or series variable"
	]

	first+: native [
		{Return the FIRST of a series then increment the series index.}
		'word [word!] "Word must refer to a series"
	]
	*/

	/* ========================================================= */

	export const _SET = new Red.Native(
		"set",
		Red.RawString.fromJsString("Sets the value(s) one or more words refer to"),
		[
			new Red.RawArgument(
				new Red.RawWord("word"),
				new Red.RawBlock([
					new Red.RawWord("any-word!"),
					new Red.RawWord("block!"),
					new Red.RawWord("object!"),
					new Red.RawWord("path!")
				]),
				Red.RawString.fromJsString("Word, object, map path or block of words to set")
			),
			new Red.RawArgument(
				new Red.RawWord("value"),
				new Red.RawBlock([new Red.RawWord("any-type!")]),
				Red.RawString.fromJsString("Value or block of values to assign to words")
			)
		],
		[
			new Red.RawFuncRefine(
				new Red.RawRefinement(new Red.RawWord("any")),
				Red.RawString.fromJsString("Allow UNSET as a value rather than causing an error"),
				[]
			),
			new Red.RawFuncRefine(
				new Red.RawRefinement(new Red.RawWord("case")),
				Red.RawString.fromJsString("Use case-sensitive comparison (path only)"),
				[]
			),
			new Red.RawFuncRefine(
				new Red.RawRefinement(new Red.RawWord("only")),
				Red.RawString.fromJsString("Block or object value argument is set as a single value"),
				[]
			),
			new Red.RawFuncRefine(
				new Red.RawRefinement(new Red.RawWord("some")),
				Red.RawString.fromJsString("None values in a block or object value argument, are not set"),
				[]
			),
		],
		new Red.RawBlock([new Red.RawWord("any-type!")]),
		$$set
	);

	/* ========================================================= */

	system$words.addWord("set", _SET);
}

export default RedNatives