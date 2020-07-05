import * as Red from "../../red-types";
import RedActions from "../actions";
import {append, insert, change} from "./string-ref";
import {$$skip} from "./series";

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

export function $$append(
	ctx:   Red.Context,
	tag:   Red.RawTag,
	value: Red.AnyType,
	_: RedActions.AppendOptions = {}
): Red.RawTag {
	append(ctx, tag.tag, value, _);
	
	return tag;
}

export function $$insert(
	ctx:   Red.Context,
	tag:   Red.RawTag,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {}
): Red.RawTag {
	return $$skip(ctx, tag, insert(ctx, tag.tag, tag.index - 1, value, _));
}

export function $$change(
	ctx:   Red.Context,
	tag:   Red.RawTag,
	value: Red.AnyType,
	_: RedActions.ChangeOptions = {}
): Red.RawTag {
	return $$skip(ctx, tag, change(ctx, tag.tag, tag.index - 1, value, _));
}