import * as Red from "../../red-types";
import RedActions from "../actions";

export function $$to(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawSetWord {
	if(spec instanceof Red.RawDatatype) {
		return new Red.RawSetWord(spec.name);
	} else if(spec instanceof Red.RawWord) {
		return new Red.RawSetWord(spec);
	} else if(spec instanceof Red.RawSetWord) {
		return spec;
	} else if(spec instanceof Red.RawLitWord || spec instanceof Red.RawGetWord) {
		return new Red.RawSetWord(spec.name);
	} else if(spec instanceof Red.RawRefinement) {
		if(spec.name instanceof Red.RawInteger) {
			throw new Error("error");
		} else {
			return new Red.RawSetWord(spec.name);
		}
	} else if(spec instanceof Red.RawIssue) {
		if(spec.value.match(/^['\d]|[,]/)) {
			throw new Error("error");
		} else {
			return new Red.RawSetWord(spec.value);
		}
	} else if(spec instanceof Red.RawString) {
		const str = spec.toJsString();
		if(str.match(/[\s$%,\/\\()\[\]{}@<>]|^['\d]/)) {
			throw new Error("error");
		} else {
			return new Red.RawSetWord(str);
		}
	} else if(spec instanceof Red.RawChar) {
		if(spec.char.match(/^[a-zA-Z_+\-*\/\.~`?!^&|=]$/)) {
			return new Red.RawSetWord(spec.char);
		} else {
			throw new Error("error");
		}
	} else if(spec instanceof Red.RawLogic) {
		return new Red.RawSetWord(spec.cond ? "true" : "false");
	} else {
		throw new Error("error");
	}
}

export function $$form(
	_ctx:   Red.Context,
	value:  Red.RawSetWord,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(value.name);
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawSetWord,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push(value.name + ":");
	return false;
}