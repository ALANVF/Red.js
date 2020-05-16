import * as Red from "../../red-types";
import RedActions from "../actions";

export function $$to(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawGetWord {
	if(spec instanceof Red.RawDatatype) {
		return new Red.RawGetWord(spec.name);
	} else if(spec instanceof Red.RawWord) {
		return new Red.RawGetWord(spec.name);
	} else if(spec instanceof Red.RawGetWord) {
		return spec;
	} else if(spec instanceof Red.RawLitWord || spec instanceof Red.RawSetWord) {
		return new Red.RawGetWord(spec.name);
	} else if(spec instanceof Red.RawRefinement) {
		if(spec.name instanceof Red.RawInteger) {
			throw new Error("error");
		} else {
			return new Red.RawGetWord(spec.name);
		}
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
		if(spec.char.match(/^[a-zA-Z_+\-*\/\.~`?!^&|=]$/)) {
			return new Red.RawGetWord(spec.char);
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
	_ctx:   Red.Context,
	value:  Red.RawGetWord,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(value.name);
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawGetWord,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push(":" + value.name);
	return false;
}