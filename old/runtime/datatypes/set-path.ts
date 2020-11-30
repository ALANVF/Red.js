import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

// $compare

// $$make

// $$to

export function $$form(
	ctx:     Red.Context,
	value:   Red.RawSetPath,
	builder: StringBuilder,
	part?:   number
) {
	const [head, ...rest] = value.path.slice(value.index - 1);

	RedActions.valueSendAction("$$form", ctx, head, builder, part);
	for(const val of rest) {
		builder.push("/");
		RedActions.valueSendAction("$$form", ctx, val, builder, part);
	}

	builder.push(":");
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawSetPath,
	builder: StringBuilder,
	indent:  number,
	_: RedActions.MoldOptions = {}
) {
	const [head, ...rest] = value.path.slice(value.index - 1);
	
	RedActions.valueSendAction("$$mold", ctx, head, builder, indent, _);
	for(const val of rest) {
		builder.push("/");
		RedActions.valueSendAction("$$mold", ctx, val, builder, indent, _);
	}

	builder.push(":");
}