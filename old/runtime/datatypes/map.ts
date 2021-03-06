import * as Red from "../../red-types";
import RedActions from "../actions";
import RedUtil from "../util";
import RedNatives from "../natives";
import {StringBuilder} from "../../helper-types";

/* Actions */

export function $$reflect(
	_ctx:  Red.Context,
	map:   Red.RawMap,
	field: string
): Red.AnyType {
	switch(field) {
		case "words": {
			return new Red.RawBlock(map.keys.map(key => key instanceof Red.RawSetWord ? key.word : key));
		}
		
		case "values": {
			return new Red.RawBlock([...map.values]);
		}
		
		case "body": {
			const out: Red.AnyType[] = [];
			
			for(let i = 0; i < map.keys.length; i++) {
				out.push(map.keys[i], map.values[i]);
			}
			
			return new Red.RawBlock(out);
		}
		
		default: {
			Red.todo();
		}
	}
}

export function $$form(
	ctx:     Red.Context,
	map:     Red.RawMap,
	builder: StringBuilder,
	_part?:  number
) {
	if(map.keys.length == 0) {
		builder.push("");
	} else {
		for(let i = 0; i < map.keys.length; i++) {
			builder.push(RedActions.$$mold(ctx, map.keys[i]).toJsString());
			builder.push(" ");
			builder.push(RedActions.$$mold(ctx, map.values[i]).toJsString());
			
			if(i + 1 < map.keys.length) {
				builder.push("^/");
			}
		}
	}
}

export function $$mold(
	ctx:     Red.Context,
	map:     Red.RawMap,
	builder: StringBuilder,
	indent:  number,
	_: RedActions.MoldOptions = {}
) {
	builder.push("#(");
	
	if(map.keys.length > 0) {
		builder.push("\n");
		const idt = "\t".repeat(indent);
		
		for(const [key, value] of RedUtil.Arrays.zip(map.keys, map.values)) {
			builder.push(idt);
			RedActions.valueSendAction("$$mold", ctx, key, builder, indent + 1, _);
			builder.push(" ");
			RedActions.valueSendAction("$$mold", ctx, value, builder, indent + 1, _);
			builder.push("\n");
		}
	}

	builder.push("\t".repeat(indent - 1));
	builder.push(")");
}

// ...

export function $$clear(
	_ctx: Red.Context,
	map:  Red.RawMap
): Red.RawMap {
	map.keys.splice(0);
	map.values.splice(0);
	
	return map;
}

// ...

export function $$remove(
	ctx: Red.Context,
	map: Red.RawMap,
	_: RedActions.RemoveOptions = {}
): Red.RawMap {
	if(_.key === undefined) {
		throw new Error("Refinement /key is required!");
	} else {
		const key = _.key;
		const eql: ((v: Red.AnyType) => boolean) = Red.isAnyWord(key)
			? (k => Red.isAnyWord(k) && k.name == key.name)
			: (k => RedNatives.$$strict_equal_q(ctx, key, k).cond);
		
		for(let i = 0; i < map.keys.length; i++) {
			if(eql(map.keys[i])) {
				map.keys.splice(i, 1);
				map.values.splice(i, 1);
				break;
			}
		}
		
		return map;
	}
}