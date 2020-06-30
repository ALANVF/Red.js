import * as Red from "../../red-types";
import RedActions from "../actions";
import RedUtil from "../util";
import RedNatives from "../natives";

/* Actions */
export function $$form(
	ctx:    Red.Context,
	map:    Red.RawMap,
	buffer: string[],
	_part?: number
): boolean {
	if(map.keys.length == 0) {
		buffer.push("");
	} else {
		for(let i = 0; i < map.keys.length; i++) {
			buffer.push(RedActions.$$mold(ctx, map.keys[i]).toJsString());
			buffer.push(" ");
			buffer.push(RedActions.$$mold(ctx, map.values[i]).toJsString());
			
			if(i + 1 < map.keys.length) {
				buffer.push("^/");
			}
		}
	}
	
	return false;
}

export function $$mold(
	ctx:    Red.Context,
	map:    Red.RawMap,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push("#(");
	
	if(map.keys.length > 0) {
		buffer.push("\n");
		const idt = "\t".repeat(indent);
		
		for(const [key, value] of RedUtil.Arrays.zip(map.keys, map.values)) {
			buffer.push(idt);
			RedActions.valueSendAction("$$mold", ctx, key, buffer, indent + 1, _);
			buffer.push(" ");
			RedActions.valueSendAction("$$mold", ctx, value, buffer, indent + 1, _);
			buffer.push("\n");
		}
	}

	buffer.push("\t".repeat(indent - 1));
	buffer.push(")");
	
	return map.keys.length > 0;
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