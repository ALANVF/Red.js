import * as Red from "../../red-types";
import RedNatives from "../natives";
import RedActions from "../actions";

// $compare

export function $$make(
	ctx: Red.Context,
	_proto: Red.AnyType,
	spec: Red.RawBlock|Red.RawTypeset
): Red.RawTypeset {
	if(spec instanceof Red.RawTypeset) {
		return spec;
	} else {
		const out: Red.RawDatatype[] = [];

		for(let value of spec.current().values) {
			if(value instanceof Red.RawWord) {
				value = RedNatives.$$get(ctx, value);
			}

			if(value instanceof Red.RawDatatype) {
				out.push(value);
			} else if(value instanceof Red.RawTypeset) {
				out.push(...value.types);
			} else {
				throw Error("error!");
			}
		}
		
		return new Red.RawTypeset(out);
	}
}

export function $$form(
	_ctx: Red.Context,
	value: Red.RawTypeset,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push("make typeset! [");
	buffer.push(value.types.map(type => type.name).join(" "));
	buffer.push("]");
	
	return false;
}

export function $$mold(
	ctx: Red.Context,
	value: Red.RawTypeset,
	buffer: string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, value, buffer, _.part);
}

// $$and_t

// $$complement

// $$or_t

// $$xor_t

// $$find