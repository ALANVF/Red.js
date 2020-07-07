import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

/* Actions */
export function $$form(
	_ctx:    Red.Context,
	_unset:  Red.RawUnset,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push("");
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	unset:   Red.RawUnset,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, unset, builder, _.part);
}