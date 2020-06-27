import * as Red from "../../red-types";
import RedActions from "../actions";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	file:   Red.RawFile,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(file.current().name.ref);
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	file:    Red.RawFile,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push("%");
	return $$form(ctx, file, buffer, _.part);
}