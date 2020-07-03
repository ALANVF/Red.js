import * as Red from "../../red-types";
import RedActions from "../actions";
import {append, insert} from "./string-ref";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	email:  Red.RawEmail,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(email.email.ref.slice(email.index - 1));
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	email:   Red.RawEmail,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, email, buffer, _.part);
}

// ...

export function $$append(
	ctx:   Red.Context,
	email: Red.RawEmail,
	value: Red.AnyType,
	_: RedActions.AppendOptions = {}
): Red.RawEmail {
	append(ctx, email.email, value, _, encodeURI);
	
	return email;
}

// ...

export function $$insert(
	ctx:   Red.Context,
	email: Red.RawEmail,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {}
): Red.RawEmail {
	email.index += insert(ctx, email.email, email.index - 1, value, _, encodeURI);
	
	return email;
}