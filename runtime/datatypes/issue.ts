import * as Red from "../../red-types";
import RedActions from "../actions";

// $$make

export function $$form(
	_ctx:   Red.Context,
	value:  Red.RawIssue,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(value.value);
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawIssue,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push("#");
	buffer.push(value.value);

	return false;
}