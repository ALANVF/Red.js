import * as Red from "../../red-types";
import RedActions from "../actions";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	_unset: Red.RawUnset,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push("");
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	unset:   Red.RawUnset,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, unset, buffer, _.part);
}