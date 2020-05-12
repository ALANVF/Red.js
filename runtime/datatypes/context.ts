import * as Red from "../../red-types";
import RedNatives from "../natives";
import RedActions from "../actions";
import {evalSingle, groupSingle} from "../eval";

/* Native functions */
// TODO: switch this to transformPath from eval.ts (this doesn't seem to be mentioned anywhere else)
export function $evalPath(
	ctx: Red.Context,
	context: Red.Context,
	value: Red.AnyType,
	isCase: boolean
): Red.AnyType {
	let getVal;

	if(value instanceof Red.RawPath) {
		if(value.path.slice(value.index-1).length == 1) {
			getVal = value = value.path.slice(value.index-1)[0];
		} else {
			getVal = value.path.slice(value.index-1)[0];
		}

		if(!(getVal instanceof Red.RawWord)) {
			getVal = evalSingle(ctx, getVal);
		}
	} else {
		getVal = value;
	}

	if(getVal instanceof Red.RawWord) {
		return RedNatives.$$get(context, getVal, {case: isCase ? [] : undefined});
	} else {
		throw new Error(`Invalid path accessor ${value}`);
	}
}

export function $setPath(
	ctx: Red.Context,
	context: Red.Context,
	value: Red.AnyType,
	newValue: Red.AnyType,
	isCase: boolean
): Red.AnyType {
	let getVal: Red.AnyType;

	if(value instanceof Red.RawPath) {
		if(value.path.slice(value.index-1).length == 1) {
			getVal = value = value.path.slice(value.index-1)[0];
		} else {
			getVal = value.path.slice(value.index-1)[0];
		}

		if(!(getVal instanceof Red.RawWord)) {
			getVal = evalSingle(ctx, getVal);
		}
	} else {
		getVal = value;
	}

	if(getVal instanceof Red.RawWord) {
		return RedNatives.$$set(context, getVal, newValue, {case: isCase ? [] : undefined});
	} else {
		throw new Error(`Invalid path accessor ${value}`);
	}
}

export function $add(
	ctx: Red.Context,
	context: Red.Context,
	word: Red.AnyType,
	_isCase: boolean
) {
	let getVal: Red.AnyType;

	if(word instanceof Red.RawPath) {
		if(word.path.slice(word.index-1).length == 1) {
			getVal = word = word.path.slice(word.index-1)[0];
		} else {
			throw new Error("error!");
		}

		if(!(getVal instanceof Red.RawWord)) {
			getVal = evalSingle(ctx, getVal);
		}
	} else {
		getVal = word;
	}

	if(getVal instanceof Red.RawWord) {
		context.words.push(getVal);
		context.values.push(new Red.RawNone()); // maybe change to unset?
	} else {
		throw new Error(`Invalid path accessor ${word}`);
	}
}

/* Actions */
export function $$make(
	ctx: Red.Context,
	_proto: Red.AnyType,
	spec: Red.RawBlock
): Red.Context {
	let blk = [...spec.values];
	const out = new Red.Context("", ctx);

	// this doesn't work quite like it does normally in Red, but it works for now
	while(blk.length > 0) {
		const head = blk[0];

		if(head instanceof Red.RawSetWord) {
			$add(ctx, out, head.word, false);
		}

		const grouped = groupSingle(out, blk);
		evalSingle(out, grouped.made);
		blk = grouped.restNodes;
	}

	return out;
}

export function $$form(
	ctx: Red.Context,
	context: Red.Context,
	buffer: string[],
	_part?: number
): boolean {
	for(let i = 0; i < context.words.length; i++) {
		buffer.push(RedActions.$$form(ctx, context.words[i]).toJsString());
		buffer.push(" ");
		buffer.push(RedActions.$$mold(ctx, context.values[i]).toJsString());
		
		if(i + 1 < context.words.length) {
			buffer.push("^/");
		}
	}
	
	return false;
}

export function $$mold(
	ctx: Red.Context,
	context: Red.Context,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push("make context! [");
	
	if(context.words.length > 0) {
		buffer.push("\n");
		const idt = "\t".repeat(indent);

		for(const word of context.words) {
			const value = context.values[context.words.indexOf(word)];
			
			buffer.push(idt);
			buffer.push(word.name + ": "); // pretty-print ws later
			
			RedActions.$valueSendAction("$$mold", ctx, value, buffer, indent + 1, _);
			buffer.push("\n");
		}
	}

	buffer.push("\t".repeat(indent - 1));
	buffer.push("]");
	return context.words.length > 0;
}