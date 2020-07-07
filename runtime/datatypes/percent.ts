import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

export function $$form(
	_ctx:    Red.Context,
	value:   Red.RawPercent,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push((value.value * 100).toString() + "%");
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawPercent,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, value, builder, _.part);
}