import * as Red from "../../red-types";
import RedActions from "../actions";
import {append, insert, change} from "./string-ref";
import {$$skip} from "./series";
import {StringBuilder} from "../../helper-types";

/* Actions */
export function $$form(
	_ctx:    Red.Context,
	email:   Red.RawEmail,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push(email.email.ref.slice(email.index - 1));
}

export function $$mold(
	ctx:     Red.Context,
	email:   Red.RawEmail,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	$$form(ctx, email, builder, _.part);
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

export function $$insert(
	ctx:   Red.Context,
	email: Red.RawEmail,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {}
): Red.RawEmail {
	return $$skip(ctx, email, insert(ctx, email.email, email.index - 1, value, _, encodeURI));
}

export function $$change(
	ctx:   Red.Context,
	email: Red.RawEmail,
	value: Red.AnyType,
	_: RedActions.ChangeOptions = {}
): Red.RawEmail {
	return $$skip(ctx, email, change(ctx, email.email, email.index - 1, value, _, encodeURI));
}