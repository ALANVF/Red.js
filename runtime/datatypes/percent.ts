import * as Red from "../../red-types";
import RedActions from "../actions";

export function $$form(
	_ctx:   Red.Context,
	value:  Red.RawPercent,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push((value.value * 100).toString() + "%");
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawPercent,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, value, buffer, _.part);
}