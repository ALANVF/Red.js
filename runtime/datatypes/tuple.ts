import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

/* Actions */
export function $$form(
	_ctx:    Red.Context,
	tuple:   Red.RawTuple,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push(tuple.values.join("."));
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	tuple:   Red.RawTuple,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, tuple, builder, _.part);
}