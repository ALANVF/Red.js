import * as Red from "../../red-types";
import RedActions from "../actions";
import {insert} from "./string-ref";

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

// ...

export function $$insert(
	ctx:   Red.Context,
	tag:   Red.RawTag,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {}
): Red.RawTag {
	tag.index += insert(ctx, tag.tag, tag.index - 1, value, _);
	
	return tag;
}