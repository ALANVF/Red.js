import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

/* Actions */
export function $$form(
	_ctx:    Red.Context,
	tuple:   Red.RawTuple,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push(tuple.values.join("."));
}

export function $$mold(
	ctx:     Red.Context,
	tuple:   Red.RawTuple,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	$$form(ctx, tuple, builder, _.part);
}