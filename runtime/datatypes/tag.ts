import * as Red from "../../red-types";
import RedActions from "../actions";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	tag:    Red.RawTag,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push("<");
	buffer.push(tag.current().tag.ref);
	buffer.push(">");
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	tag:     Red.RawTag,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, tag, buffer, _.part);
}