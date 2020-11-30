import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

export function $$form(
	_ctx:   Red.Context,
	bitset: Red.RawBitset,
	builder: StringBuilder,
	_part?: number
) {
	builder.push("make bitset! ");
	
	if(bitset.negated) builder.push("[not ");
	
	builder.push("#{");
	builder.push([...bitset.bytes].map(byte =>
		(byte < 16 ? "0" : "") + byte.toString(16).toUpperCase()
	).join(""));
	builder.push("}");
	
	if(bitset.negated) builder.push("]");
}

export function $$mold(
	ctx:     Red.Context,
	bitset:  Red.RawBitset,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	$$form(ctx, bitset, builder, _.part);
}

// ...

export function $$clear(
	_ctx:   Red.Context,
	bitset: Red.RawBitset
): Red.RawBitset {
	bitset.bytes = new Uint8Array();
	
	return bitset;
}

// ...

export function $$remove(
	_ctx:   Red.Context,
	bitset: Red.RawBitset,
	_: RedActions.RemoveOptions = {}
): Red.RawBitset {
	if(_.key === undefined) {
		throw new Error("Refinement /key is required!");
	} else {
		const key = _.key;
		
		if(key instanceof Red.RawInteger) {
			if(key.value < 0) {
				throw new Error("Index out of bounds!");
			} else {
				bitset.setBit(key.value, false);
			}
		} else if(key instanceof Red.RawChar) {
			bitset.setBit(key.char, false);
		} else {
			throw new TypeError(`Unexpected ${Red.typeName(key)}`);
		}
	}
	
	return bitset;
}