import * as Red from "../../red-types";
import RedActions from "../actions";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	email:  Red.RawEmail,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push((email.user + "@" + email.host).slice(email.index - 1));
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