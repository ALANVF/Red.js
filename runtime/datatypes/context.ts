import * as Red from "../../red-types";
import RedActions from "../actions";
import {evalSingle, groupSingle, ExprType} from "../eval";

/* Native actions */
export function $evalPath(
	ctx:     Red.Context,
	context: Red.Context,
	value:   Red.AnyType,
	isCase:  boolean
): Red.AnyType {
	let getVal: Red.AnyType;

	if(value instanceof Red.RawWord) {
		getVal = value;
	} else {
		getVal = evalSingle(ctx, value);
	}

	if(getVal instanceof Red.RawWord) {
		return context.getWord(getVal.name, isCase);
	} else {
		throw new Error(`Invalid accessor ${value}`);
	}
}

export function $setPath(
	ctx:      Red.Context,
	context:  Red.Context,
	value:    Red.AnyType,
	newValue: Red.AnyType,
	isCase:   boolean
): Red.AnyType {
	let getVal: Red.AnyType;

	if(value instanceof Red.RawWord) {
		getVal = value;
	} else {
		getVal = evalSingle(ctx, value);
	}

	if(getVal instanceof Red.RawWord) {
		context.setWord(getVal.name, newValue, isCase);
		return newValue;
	} else {
		throw new Error(`Invalid accessor ${value}`);
	}
}

export function $add(
	ctx:     Red.Context,
	context: Red.Context,
	value:   Red.AnyType,
	isCase:  boolean
) {
	let getVal: Red.AnyType;

	if(value instanceof Red.RawWord) {
		getVal = value;
	} else {
		getVal = evalSingle(ctx, value);
	}

	if(getVal instanceof Red.RawWord) {
		context.addWord(getVal.name, new Red.RawNone(), isCase);
	} else {
		throw new Error(`Invalid accessor ${value}`);
	}
}

/* Actions */
export function $$make(
	ctx:    Red.Context,
	_proto: Red.AnyType,
	spec:   Red.RawBlock
): Red.Context {
	let blk: ExprType[] = [...spec.values];
	const out = new Red.Context(ctx);

	// this doesn't work quite like it does normally in Red, but it works for now
	while(blk.length > 0) {
		const head = blk[0];

		if(head instanceof Red.RawSetWord) {
			blk.shift();

			const grouped = groupSingle(out, blk);
			
			out.addWord(head.name, evalSingle(out, grouped.made));
			blk = grouped.restNodes;
		} else {
			const grouped = groupSingle(out, blk);
			evalSingle(out, grouped.made);
			blk = grouped.restNodes;
		}
	}

	out.outer = undefined;
	
	return out;
}

export function $$form(
	ctx:     Red.Context,
	context: Red.Context,
	buffer:  string[],
	_part?:  number
): boolean {
	for(let i = 0; i < context.words.length; i++) {
		buffer.push(context.words[i]);
		buffer.push(" ");
		buffer.push(RedActions.$$mold(ctx, context.values[i]).toJsString());
		
		if(i + 1 < context.words.length) {
			buffer.push("^/");
		}
	}
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	context: Red.Context,
	buffer:  string[],
	indent:  number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push("make context! [");
	
	if(context.words.length > 0) {
		buffer.push("\n");
		const idt = "\t".repeat(indent);

		for(const word of context.words) {
			const value = context.getWord(word);
			
			buffer.push(idt);
			buffer.push(word + ": "); // pretty-print ws later
			RedActions.valueSendAction("$$mold", ctx, value, buffer, indent + 1, _);
			buffer.push("\n");
		}
	}

	buffer.push("\t".repeat(indent - 1));
	buffer.push("]");
	
	return context.words.length > 0;
}