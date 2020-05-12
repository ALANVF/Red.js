import {tokenize} from "../tokenizer";
import {pre, pre1} from "./preprocesser";
import {system, system$, system$words} from "./system";
import {evalSingle, groupSingle} from "./eval";
import * as Red from "../red-types";
import RedActions from "./actions";

module RedNatives {
	// debugging
	export function $$print(
		_ctx: Red.Context,
		val:  Red.AnyType
	) {
		if(val instanceof Red.RawString) {
			console.log(val.toJsString());
		} else {
			console.log(val);
		}

		return new Red.RawUnset();
	}

	// also debugging
	export function $$prin(
		ctx: Red.Context,
		val: Red.AnyType
	) {
		if(process == null) {
			throw Error('Red.js native! "system/words/prin" may only be used in node.js supported environments!');
		} else {
			process.stdout.write(RedActions.$$form(ctx, val).toJsString());
			return new Red.RawUnset();
		}
	};

	export function $$if(
		ctx:     Red.Context,
		cond:    Red.AnyType,
		thenBlk: Red.RawBlock
	): Red.AnyType {
		if(cond instanceof Red.RawNone || (cond instanceof Red.RawLogic && !cond.cond)) {
			return new Red.RawNone();
		} else {
			return $$do(ctx, thenBlk);
		}
	}

	export function $$unless(
		ctx:     Red.Context,
		cond:    Red.AnyType,
		thenBlk: Red.RawBlock
	): Red.AnyType {
		if(cond instanceof Red.RawNone || (cond instanceof Red.RawLogic && !cond.cond)) {
			return $$do(ctx, thenBlk);
		} else {
			return new Red.RawNone();
		}
	}

	export function $$either(
		ctx:     Red.Context,
		cond:    Red.AnyType,
		thenBlk: Red.RawBlock,
		elseBlk: Red.RawBlock
	): Red.AnyType {
		if(cond instanceof Red.RawNone || (cond instanceof Red.RawLogic && !cond.cond)) {
			return $$do(ctx, elseBlk);
		} else {
			return $$do(ctx, thenBlk);
		}
	}

	export function $$any(
		ctx:  Red.Context,
		cond: Red.RawBlock
	): Red.AnyType {
		let blk = [...cond.values.slice(cond.index-1)];
		let res;

		do {
			const made = groupSingle(ctx, blk);
			res = evalSingle(ctx, made.made);
			blk = made.restNodes;
		} while((res instanceof Red.RawNone || (res instanceof Red.RawLogic && !res.cond)) && blk.length > 0);
		
		if(res instanceof Red.RawNone || (res instanceof Red.RawLogic && !res.cond)) {
			return new Red.RawNone();
		} else {
			return res;
		}
	}
	
	export function $$all(
		ctx:  Red.Context,
		cond: Red.RawBlock
	): Red.AnyType {
		let blk = [...cond.values.slice(cond.index-1)];
		let res;

		do {
			const made = groupSingle(ctx, blk);
			res = evalSingle(ctx, made.made);
			blk = made.restNodes;
		} while(!(res instanceof Red.RawNone || (res instanceof Red.RawLogic && !res.cond)) && blk.length > 0);

		if(res instanceof Red.RawNone || (res instanceof Red.RawLogic && !res.cond)) {
			return new Red.RawNone();
		} else {
			return res;
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
			const c = $$do(ctx, cond);

			if(c instanceof Red.RawNone || (c instanceof Red.RawLogic && !c.cond)) {
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

		return ret || new Red.RawUnset();
	}

	export function $$until(
		ctx:  Red.Context,
		body: Red.RawBlock
	): Red.AnyType {
		let status = true;
		let ret;

		while(status) {
			try {
				const c = $$do(ctx, body);
				
				if(c instanceof Red.RawNone || (c instanceof Red.RawLogic && !c.cond)) {
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

		return ret || new Red.RawUnset();
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

		return ret || new Red.RawUnset();
	}

	export function $$repeat(
		ctx:   Red.Context,
		word:  Red.RawWord,
		value: Red.RawInteger,
		body:  Red.RawBlock
	): Red.AnyType {
		let status = true;
		let ret;

		let times = value.value;
		if(times < 0) throw Error(`Cannot iterate ${times} times`);

		for(let i = 1; i < times+1 && status; i++) {
			$$set(ctx, word, new Red.RawInteger(i));

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

		return ret || new Red.RawUnset();
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
						throw(e);
				}
			}
		}

		return ret || new Red.RawUnset();
	}

	export function $$foreach(
		ctx:    Red.Context,
		word:   Red.RawWord|Red.RawBlock,
		series: Red.RawSeries,
		body:   Red.RawBlock
	): Red.AnyType {
		let status = true;
		let ret;

		if(word instanceof Red.RawWord) {
			for(let i = 1; i < series.index+1 && status; i++) {
				$$set(ctx, word, RedActions.$$pick(ctx, series, new Red.RawInteger(i)));

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
		} else {
			Red.todo();
		}

		return ret || new Red.RawUnset();
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
			system.getPath(new Red.RawPath([system$words, new Red.RawWord("function!")])), // TODO: provide this automatically in system.ts
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
			system.getPath(new Red.RawPath([system$words, new Red.RawWord("function!")])),
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
		let ret;
		let _cases = cases.values.slice(cases.index-1);
		const comp = _.strict !== undefined ? $$strict_equal_q : $$equal_q;
		
		while(_cases.length != 0) {
			let next = groupSingle(ctx, _cases);
			const matchExpr = evalSingle(ctx, next.made);
			
			_cases = next.restNodes;
			next = groupSingle(ctx, _cases);
			_cases = next.restNodes;

			const matchBlock = evalSingle(ctx, next.made);

			if(!(matchBlock instanceof Red.RawBlock)) {
				throw TypeError("Expected block! but got " + Red.TYPE_NAME(matchBlock));
			}

			if(comp(ctx, value, matchExpr).cond) {
				ret = $$do(ctx, matchBlock);
				if(_.all === undefined) break;
			}
		}

		if(ret == null && _.default !== undefined && _.default[0] != null) {
			ret = $$do(ctx, _.default[0]);
		}

		return ret || new Red.RawNone();
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
		if(Red.isAnyWord(value) || Red.isAnyPath(value)) {
			return $$get(ctx, value as Red.RawAnyWord|Red.RawAnyPath);
		} else if(value instanceof Red.RawParen || value instanceof Red.RawBlock) {
			let val = new Red.RawBlock(value.values.slice(value.index-1));

			if(_.expand !== undefined)
				val = pre(ctx, val);
			else
				val = pre1(ctx, val).body
			
			if(_.next !== undefined) {
				return Red.todo();
			} else {
				if(val.values.length == 0) {
					return new Red.RawUnset();
				}
				
				let last: Red.AnyType = new Red.RawUnset();
				let blk = val.values;

				while(blk.length > 0) {
					const grouped = groupSingle(ctx, blk);
					last = evalSingle(ctx, grouped.made);
					blk = grouped.restNodes;
				}
				
				return last;
			}
		} else if(value instanceof Red.RawFile) {
			return Red.todo();
		} else if(value instanceof Red.RawString) { // I don't remember what was happening here...
			let out = new Red.RawBlock(tokenize(value.values.map(c=>c.char).join().slice(value.index-1)).made);
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
			let blk = value.values.slice(value.index-1);

			while(blk.length > 0) {
				const res = groupSingle(ctx, blk);
				made.push(evalSingle(ctx, res.made));
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
		const blk = [...value.values.slice(value.index-1)];
		
		if(_.into !== undefined) {
			Red.todo();
		}

		blk.forEach((e, i) => {
			if(e instanceof Red.RawParen) {
				const res = evalSingle(ctx, e);

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
	// also, accessing system/words needs to be fixed
	export function $$get(
		ctx:  Red.Context,
		name: Red.RawAnyWord|Red.RawRefinement|Red.RawPath|Red.RawObject,
		_: {
			any?:  [],
			case?: []
		} = {}
	): Red.AnyType {
		let word: Red.RawWord;

		if(Red.isAnyWord(name)) {
			word = name.word;
		} else {
			return Red.todo();
		}

		const fres = ctx.findWord(word, _.case !== undefined);
		const fresS = Red.Context.$.findPath(new Red.RawPath([system$, system$words, word]), _.case !== undefined);
		const fresG = Red.Context.$.findWord(word, _.case !== undefined);

		if(fres != -1) {
			const res = ctx.getWord(word, _.case !== undefined);

			if(!(res instanceof Red.RawUnset && _.any === undefined)) {
				return res;
			}
		} else if(fresS != -1) {
			const resS = Red.Context.$.getPath(new Red.RawPath([system$, system$words, word]), _.case !== undefined);
			
			if(!(resS instanceof Red.RawUnset && _.any === undefined)) {
				return resS;
			}
		} else if(fresG != -1) {
			const resG = Red.Context.$.getWord(word, _.case !== undefined);
			
			if(!(resG instanceof Red.RawUnset && _.any === undefined)) {
				return resG;
			}
		}

		if(_.any === undefined) {
			throw new Error(`${word.name} has no value!`);
		} else {
			return new Red.RawUnset();
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
		ctx:   Red.Context,
		name:  Red.RawAnyWord|Red.RawPath|Red.RawBlock|Red.RawObject,
		value: Red.AnyType,
		_: {
			any?:  [],
			case?: [],
			only?: [],
			some?: []
		} = {}
	): Red.AnyType {
		let word: Red.RawWord;
		
		if(Red.isAnyWord(name)) {
			word = name.word;
		} else {
			return Red.todo();
		}
		
		if(ctx == Red.Context.$) {
			return Red.Context.$.setPath(new Red.RawPath([system$, system$words, word]), value);
		} else {
			if(ctx.findWord(word) != -1) {
				return ctx.setWord(word, value);
			} else {
				return $$set(ctx.outer!, word, value, _);
			}
		}
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
		return new Red.RawLogic(value instanceof Red.RawNone || (value instanceof Red.RawLogic && !value.cond));
	}
	
	export function $$type_q(
		_ctx:  Red.Context,
		value: Red.AnyType,
		_: {
			word?: []
		} = {}
	): Red.AnyType {
		if(_.word === undefined) {
			const words = system.getWord(system$words) as Red.Context;
			return words.getWord(new Red.RawWord(Red.TYPE_NAME(value)));
		} else {
			return new Red.RawWord(Red.TYPE_NAME(value));
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
	
	export function $$break(
		_ctx: Red.Context,
		_: {
			return?: [Red.AnyType]
		} = {}
	): never {
		throw new Red.CFBreak(_.return);
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
		Red.RawString.fromNormalString("Sets the value(s) one or more words refer to"),
		[
			new Red.RawArgument(
				new Red.RawWord("word"),
				new Red.RawBlock([
					new Red.RawWord("any-word!"),
					new Red.RawWord("block!"),
					new Red.RawWord("object!"),
					new Red.RawWord("path!")
				]),
				Red.RawString.fromNormalString("Word, object, map path or block of words to set")
			),
			new Red.RawArgument(
				new Red.RawWord("value"),
				new Red.RawBlock([new Red.RawWord("any-type!")]),
				Red.RawString.fromNormalString("Value or block of values to assign to words")
			)
		],
		[
			new Red.RawFuncRefine(
				new Red.RawRefinement(new Red.RawWord("any")),
				Red.RawString.fromNormalString("Allow UNSET as a value rather than causing an error"),
				[]
			),
			new Red.RawFuncRefine(
				new Red.RawRefinement(new Red.RawWord("case")),
				Red.RawString.fromNormalString("Use case-sensitive comparison (path only)"),
				[]
			),
			new Red.RawFuncRefine(
				new Red.RawRefinement(new Red.RawWord("only")),
				Red.RawString.fromNormalString("Block or object value argument is set as a single value"),
				[]
			),
			new Red.RawFuncRefine(
				new Red.RawRefinement(new Red.RawWord("some")),
				Red.RawString.fromNormalString("None values in a block or object value argument, are not set"),
				[]
			),
		],
		new Red.RawBlock([new Red.RawWord("any-type!")]),
		$$set
	);

	/* ========================================================= */

	system.setPath(new Red.RawPath([system$words, new Red.RawWord("set")]), _SET);
}

export default RedNatives