import * as Red from "../../red-types";
import RedActions from "../actions";
import { StringBuilder } from "../../helper-types";

// $$make

// $$to

export function $$form(
	_ctx:    Red.Context,
	binary:  Red.RawBinary,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push("#{");
	builder.push(binary.bytes.ref.slice(binary.index - 1).toString("hex").toUpperCase());
	builder.push("}");
}

export function $$mold(
	ctx:     Red.Context,
	binary:  Red.RawBinary,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	$$form(ctx, binary, builder, _.part);
}