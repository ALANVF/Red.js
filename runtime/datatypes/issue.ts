import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

// $$make

export function $$form(
	_ctx:    Red.Context,
	value:   Red.RawIssue,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push(value.value);
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawIssue,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	builder.push("#");
	builder.push(value.value);

	return false;
}