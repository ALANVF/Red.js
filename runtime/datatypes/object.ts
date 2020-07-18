import * as Red from "../../red-types";
import RedActions from "../actions";
import {evalSingle, groupSingle, ExprType} from "../eval";
import {StringBuilder} from "../../helper-types";

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

export function $$reflect(
	_ctx:  Red.Context,
	obj:   Red.RawObject,
	field: string
): Red.AnyType {
	switch(field) {
		case "changed": {
			Red.difficult();
		}
		
		case "class": {
			return new Red.RawInteger(obj.id);
		}
		
		case "words": {
			return new Red.RawBlock(obj.words.map(word => new Red.RawWord(word)));
		}
		
		case "values": {
			return new Red.RawBlock([...obj.values]);
		}
		
		case "body": {
			const out: Red.AnyType[] = [];
			
			for(let i = 0; i < obj.words.length; i++) {
				out.push(new Red.RawSetWord(obj.words[i]), obj.values[i]);
			}
			
			return new Red.RawBlock(out);
		}
		
		case "owner": {
			Red.difficult();
		}
		
		default: {
			Red.todo();
		}
	}
}

export function $$form(
	ctx:     Red.Context,
	obj:     Red.RawObject,
	builder: StringBuilder,
	_part?:  number
) {
	for(let i = 0; i < obj.words.length; i++) {
		builder.push(obj.words[i]);
		builder.push(" ");
		builder.push(RedActions.$$mold(ctx, obj.values[i]).toJsString());
		
		if(i + 1 < obj.words.length) {
			builder.push("^/");
		}
	}
}

export function $$mold(
	ctx:     Red.Context,
	obj:     Red.RawObject,
	builder: StringBuilder,
	indent:  number,
	_: RedActions.MoldOptions = {}
) {
	builder.push("make object! [");
	
	if(obj.words.length > 0) {
		builder.push("\n");
		const idt = " ".repeat(indent*4);

		for(const word of obj.words) {
			const value = obj.getWord(word);
			
			builder.push(idt);
			builder.push(word + ": "); // pretty-print ws later
			RedActions.valueSendAction("$$mold", ctx, value, builder, indent + 1, _);
			builder.push("\n");
		}
	}

	builder.push(" ".repeat((indent-1)*4));
	builder.push("]");
}