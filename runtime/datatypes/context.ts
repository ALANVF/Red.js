import * as Red from "../../red-types";
import RedActions from "../actions";
import {evalSingle, groupSingle, ExprType} from "../eval";
import {StringBuilder} from "../../helper-types";

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
		getVal = evalSingle(ctx, value, false);
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
		getVal = evalSingle(ctx, value, false);
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
		getVal = evalSingle(ctx, value, false);
	}

	if(getVal instanceof Red.RawWord) {
		context.addWord(getVal.name, Red.RawNone.none, isCase);
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
			out.addWord(head.name, evalSingle(out, grouped.made, grouped.noEval));
			blk = grouped.restNodes;
		} else {
			const grouped = groupSingle(out, blk);
			evalSingle(out, grouped.made, grouped.noEval);
			blk = grouped.restNodes;
		}
	}

	out.outer = undefined;
	
	return out;
}

export function $$form(
	ctx:     Red.Context,
	context: Red.Context,
	builder: StringBuilder,
	_part?:  number
) {
	for(let i = 0; i < context.words.length; i++) {
		builder.push(context.words[i]);
		builder.push(" ");
		builder.push(RedActions.$$mold(ctx, context.values[i]).toJsString());
		
		if(i + 1 < context.words.length) {
			builder.push("^/");
		}
	}
}

export function $$mold(
	ctx:     Red.Context,
	context: Red.Context,
	builder: StringBuilder,
	indent:  number,
	_: RedActions.MoldOptions = {}
) {
	builder.push("make context! [");
	
	if(context.words.length > 0) {
		builder.push("\n");
		const idt = " ".repeat(indent*4);

		for(const word of context.words) {
			const value = context.getWord(word);
			
			builder.push(idt);
			builder.push(word + ": "); // pretty-print ws later
			RedActions.valueSendAction("$$mold", ctx, value, builder, indent + 1, _);
			builder.push("\n");
		}
	}

	builder.push(" ".repeat((indent-1)*4));
	builder.push("]");
}