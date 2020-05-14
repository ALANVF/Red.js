import * as RedTypes from "./red-types";
import * as RedParser from "./tokenizer";
import * as RedPre from "./runtime/preprocesser";
import RedUtil from "./runtime/util";
import * as RedSystem from "./runtime/system";
import * as RedEval from "./runtime/eval";
import RedNatives from "./runtime/natives";
import RedActions from "./runtime/actions";
import {readFileSync} from "fs";

export class FileState {
	from?:  FileState;
	title?: RedTypes.RawString;
	file?:  RedTypes.RawFile;
	// ... add more header stuff later

	constructor(
		spec:  RedTypes.RawBlock,
		from?: FileState
	) {
		const _spec = spec.values;

		this.from = from;
		
		while(_spec.length != 0) {
			const n1 = _spec.shift();
			const n2 = _spec.shift();

			if(n1 instanceof RedTypes.RawSetWord && n2 !== undefined) {
				if(this.file === undefined && n1.word.name.toLowerCase() == "file" && n2 instanceof RedTypes.RawFile) {
					this.file = n2;
				} else if(this.title === undefined && n1.word.name.toLowerCase() == "title" && n2 instanceof RedTypes.RawString) {
					this.title = n2;
				}
			}
		}
	}
}

export function evalTopLevel(
	input: string,
	ctx:   RedTypes.Context = RedTypes.Context.$
): RedTypes.AnyType {
	const parsed = RedPre.pre(ctx, new RedTypes.RawBlock(RedParser.tokenize(input).made));
	let ret: RedTypes.AnyType = new RedTypes.RawNone();
	let res: RedEval.GroupSingleResult = {made: new RedTypes.RawUnset(), restNodes: []};
	let body = parsed.values;
	
	try {
		while(body.length > 0) {
			res = RedEval.groupSingle(ctx, body);
			body = res.restNodes;
			ret = RedEval.evalSingle(ctx, res.made);
		}
	} catch(e) {
		switch(e.constructor) {
			case RedTypes.CFBreak:
				throw Error("Throw Error: Nothing to break (in Red file <anon>)");

			case RedTypes.CFContinue:
				throw Error("Throw Error: Nothing to continue (in Red file <anon>)");

			case RedTypes.CFReturn:
				throw Error("Throw Error: Nothing to return (in Red file <anon>)");

			default:
				console.error("Error in Red file <anon> near: ", RedEval.stringifyRed(ctx, res ? res.made : body[0]));
				throw e;
		}
	}

	return ret;
}

export function evalFile(
	filePath:    string,
	outerState?: FileState,
	ctx:         RedTypes.Context = RedSystem.system$words
) {
	const src = readFileSync(filePath).toString();
	let parsed = new RedTypes.RawBlock(RedParser.tokenize(src).made);
	let state: FileState;

	while(true) {
		const n1 = parsed.values.shift();
		const n2 = parsed.values.shift();

		if(n1 instanceof RedTypes.RawWord && n1.name.toLowerCase() == "red" && n2 instanceof RedTypes.RawBlock) {
			state = new FileState(n2, outerState);
			break;
		}
	}

	parsed = RedPre.pre(ctx, parsed);

	var body = parsed.values;
	let res: RedEval.GroupSingleResult = {made: new RedTypes.RawUnset(), restNodes: []};
	
	try {
		while(body.length > 0) {
			res = RedEval.groupSingle(ctx, body);
			body = res.restNodes;
			RedEval.evalSingle(ctx, res.made);
		}
	} catch(e) {
		switch(e.constructor) {
			case RedTypes.CFBreak:
				throw Error(`Throw Error: Nothing to break (in Red file ${state.file ? "%"+state.file.name : "<anon>"})`);

			case RedTypes.CFContinue:
				throw Error(`Throw Error: Nothing to continue (in Red file ${state.file ? "%"+state.file.name : "<anon>"})`);

			case RedTypes.CFReturn:
				throw Error(`Throw Error: Nothing to return (in Red file ${state.file ? "%"+state.file.name : "<anon>"})`);

			default:
				console.error(`Error in Red file ${state.file ? "%"+state.file.name : "<anon>"} near: `, RedEval.stringifyRed(ctx, res ? res.made : body[0]));
				throw e;
		}
	}
}

export function evalCode(
	code:        string,
	outerState?: FileState,
	ctx:         RedTypes.Context = RedSystem.system$words
): RedTypes.AnyType {
	let state: FileState;
	let parsed = new RedTypes.RawBlock(RedParser.tokenize(code).made);

	while(true) {
		const n1 = parsed.values.shift();
		const n2 = parsed.values.shift();

		if(n1 instanceof RedTypes.RawWord && n1.name.toLowerCase() == "red" && n2 instanceof RedTypes.RawBlock) {
			state = new FileState(n2, outerState);
			break;
		}
	}

	parsed = RedPre.pre(ctx, parsed);

	let body = parsed.values;
	let res: RedEval.GroupSingleResult = {made: new RedTypes.RawUnset(), restNodes: []};
	let value: RedTypes.AnyType = new RedTypes.RawUnset();
	
	try {
		while(body.length > 0) {
			res = RedEval.groupSingle(ctx, body);
			body = res.restNodes;
			value = RedEval.evalSingle(ctx, res.made);
		}
	} catch(e) {
		switch(e.constructor) {
			case RedTypes.CFBreak:
				throw Error(`Throw Error: Nothing to break (in Red file ${state.file ? "%"+state.file.name : "<anon>"})`);

			case RedTypes.CFContinue:
				throw Error(`Throw Error: Nothing to continue (in Red file ${state.file ? "%"+state.file.name : "<anon>"})`);

			case RedTypes.CFReturn:
				throw Error(`Throw Error: Nothing to return (in Red file ${state.file ? "%"+state.file.name : "<anon>"})`);

			default:
				console.error(`Error in Red file ${state.file ? "%"+state.file.name : "<anon>"} near: `, RedEval.stringifyRed(ctx, res ? res.made : body[0]));
				throw e;
		}
	}

	return value;
}

export function evalRed(
	code: string,
	ctx:  RedTypes.Context = RedSystem.system$words
): RedTypes.AnyType {
	const parsed = RedPre.pre(ctx, new RedTypes.RawBlock(RedParser.tokenize(code).made));
	let body = parsed.values;
	let res: RedEval.GroupSingleResult = {made: new RedTypes.RawUnset(), restNodes: []};
	let value: RedTypes.AnyType = new RedTypes.RawUnset();
	
	try {
		while(body.length > 0) {
			res = RedEval.groupSingle(ctx, body);
			body = res.restNodes;
			value = RedEval.evalSingle(ctx, res.made);
		}
	} catch(e) {
		switch(e.constructor) {
			case RedTypes.CFBreak:
				throw Error("Throw Error: Nothing to break (in Red file <anon>)");

			case RedTypes.CFContinue:
				throw Error("Throw Error: Nothing to continue (in Red file <anon>)");

			case RedTypes.CFReturn:
				throw Error("Throw Error: Nothing to return (in Red file <anon>)");

			default:
				console.error("Error in Red file <anon> near: ", RedEval.stringifyRed(ctx, res ? res.made : body[0]));
				throw e;
		}
	}

	return value;
}

export {
	RedTypes as Types,
	RedParser as Parser,
	RedPre as Pre,
	RedUtil as Util,
	RedSystem as System,
	RedEval as Eval,
	RedNatives as Natives,
	RedActions as Actions
};