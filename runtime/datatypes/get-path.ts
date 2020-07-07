import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

// $compare

// $$make

// $$to

export function $$form(
	ctx:    Red.Context,
	value:  Red.RawGetPath,
	builder: StringBuilder,
	part?:  number
): boolean {
	const [head, ...rest] = value.path.slice(value.index - 1);

	builder.push(":");
	RedActions.valueSendAction("$$form", ctx, head, builder, part);
	for(const val of rest) {
		builder.push("/");
		RedActions.valueSendAction("$$form", ctx, val, builder, part);
	}

	return false;
}

export function $$mold(
	ctx:    Red.Context,
	value:  Red.RawGetPath,
	builder: StringBuilder,
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const [head, ...rest] = value.path.slice(value.index - 1);
	
	builder.push(":");
	RedActions.valueSendAction("$$mold", ctx, head, builder, indent, _);
	for(const val of rest) {
		builder.push("/");
		RedActions.valueSendAction("$$mold", ctx, val, builder, indent, _);
	}

	return false;
}