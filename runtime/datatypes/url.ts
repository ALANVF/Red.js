import * as Red from "../../red-types";
import RedActions from "../actions";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	url:    Red.RawUrl,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(url.url.slice(url.index - 1));
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	url:     Red.RawUrl,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, url, buffer, _.part);
}