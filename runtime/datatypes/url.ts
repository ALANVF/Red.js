import * as Red from "../../red-types";
import RedActions from "../actions";
import {append, insert} from "./string-ref";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	url:    Red.RawUrl,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(url.url.ref.slice(url.index - 1));
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

// ...

export function $$append(
	ctx:   Red.Context,
	url:   Red.RawUrl,
	value: Red.AnyType,
	_: RedActions.AppendOptions = {}
): Red.RawUrl {
	append(ctx, url.url, value, _, encodeURI);
	
	return url;
}

// ...

export function $$insert(
	ctx:   Red.Context,
	url:   Red.RawUrl,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {}
): Red.RawUrl {
	url.index += insert(ctx, url.url, url.index - 1, value, _, encodeURI);
	
	return url;
}