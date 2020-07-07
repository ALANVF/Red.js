import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

export function $$to(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawGetWord {
	if(spec instanceof Red.RawDatatype || spec instanceof Red.RawWord || spec instanceof Red.RawLitWord || spec instanceof Red.RawSetWord) {
		return new Red.RawGetWord(spec.name);
	} else if(spec instanceof Red.RawGetWord) {
		return spec;
	} else if(spec instanceof Red.RawRefinement) {
		return new Red.RawGetWord(spec.word.name);
	} else if(spec instanceof Red.RawIssue) {
		if(spec.value.match(/^['\d]|[,]/)) {
			throw new Error("error");
		} else {
			return new Red.RawGetWord(spec.value);
		}
	} else if(spec instanceof Red.RawString) {
		const str = spec.toJsString();
		if(str.match(/[\s$%,\/\\()\[\]{}@<>]|^['\d]/)) {
			throw new Error("error");
		} else {
			return new Red.RawGetWord(str);
		}
	} else if(spec instanceof Red.RawChar) {
		if(spec.toJsChar().match(/^[a-zA-Z_+\-*\/\.~`?!^&|=]$/)) {
			return new Red.RawGetWord(spec.toJsChar());
		} else {
			throw new Error("error");
		}
	} else if(spec instanceof Red.RawLogic) {
		return new Red.RawGetWord(spec.cond ? "true" : "false");
	} else {
		throw new Error("error");
	}
}

export function $$form(
	_ctx:    Red.Context,
	value:   Red.RawGetWord,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push(value.name);
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawGetWord,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	builder.push(":" + value.name);
	return false;
}