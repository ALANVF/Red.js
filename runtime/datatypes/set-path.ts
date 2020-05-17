import * as Red from "../../red-types";
import RedActions from "../actions";

// $compare

// $$make

// $$to

export function $$form(
	ctx:    Red.Context,
	value:  Red.RawSetPath,
	buffer: string[],
	part?:  number
): boolean {
	const [head, ...rest] = value.path.slice(value.index - 1);

	RedActions.valueSendAction("$$form", ctx, head, buffer, part);
	for(const val of rest) {
		buffer.push("/");
		RedActions.valueSendAction("$$form", ctx, val, buffer, part);
	}

	buffer.push(":");

	return false;
}

export function $$mold(
	ctx:    Red.Context,
	value:  Red.RawSetPath,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const [head, ...rest] = value.path.slice(value.index - 1);
	
	RedActions.valueSendAction("$$mold", ctx, head, buffer, indent, _);
	for(const val of rest) {
		buffer.push("/");
		RedActions.valueSendAction("$$mold", ctx, val, buffer, indent, _);
	}

	buffer.push(":");

	return false;
}