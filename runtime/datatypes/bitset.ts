import * as Red from "../../red-types";
import RedActions from "../actions";

export function $$form(
	_ctx:   Red.Context,
	bitset: Red.RawBitset,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push("make bitset! ");
	
	if(bitset.negated) buffer.push("[not ");
	
	buffer.push("#{");
	buffer.push([...bitset.bytes].map(byte =>
		(byte < 16 ? "0" : "") + byte.toString(16).toUpperCase()
	).join(""));
	buffer.push("}");
	
	if(bitset.negated) buffer.push("]");
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	bitset:  Red.RawBitset,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, bitset, buffer, _.part);
}

// ...

export function $$clear(
	_ctx:   Red.Context,
	bitset: Red.RawBitset
): Red.RawBitset {
	bitset.bytes = new Uint8Array();
	
	return bitset;
}