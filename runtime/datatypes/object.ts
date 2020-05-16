import * as Red from "../../red-types";
import RedActions from "../actions";
import {evalSingle, groupSingle, ExprType} from "../eval";

export function $$make(
	ctx:   Red.Context,
	proto: Red.AnyType,
	spec:  Red.RawBlock
): Red.Context {
	let blk: ExprType[] = [...spec.values];
	const out = new Red.RawObject(ctx, proto instanceof Red.RawObject ? proto : undefined);

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
	ctx:    Red.Context,
	obj:    Red.RawObject,
	buffer: string[],
	_part?: number
): boolean {
	for(let i = 0; i < obj.words.length; i++) {
		buffer.push(obj.words[i]);
		buffer.push(" ");
		buffer.push(RedActions.$$mold(ctx, obj.values[i]).toJsString());
		
		if(i + 1 < obj.words.length) {
			buffer.push("^/");
		}
	}
	
	return false;
}

export function $$mold(
	ctx:    Red.Context,
	obj:    Red.RawObject,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push("make object! [");
	
	if(obj.words.length > 0) {
		buffer.push("\n");
		const idt = "\t".repeat(indent);

		for(const word of obj.words) {
			const value = obj.getWord(word);
			
			buffer.push(idt);
			buffer.push(word + ": "); // pretty-print ws later
			RedActions.valueSendAction("$$mold", ctx, value, buffer, indent + 1, _);
			buffer.push("\n");
		}
	}

	buffer.push("\t".repeat(indent - 1));
	buffer.push("]");
	
	return obj.words.length > 0;
}