import * as Red from "../../red-types";
import RedActions from "../actions";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	tuple:  Red.RawTuple,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(tuple.values.join("."));
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	tuple:   Red.RawTuple,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, tuple, buffer, _.part);
}