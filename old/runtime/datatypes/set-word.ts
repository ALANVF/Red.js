import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

export function $$to(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawSetWord {
	if(spec instanceof Red.RawDatatype || spec instanceof Red.RawWord || spec instanceof Red.RawLitWord || spec instanceof Red.RawGetWord) {
		return new Red.RawSetWord(spec.name);
	} else if(spec instanceof Red.RawSetWord) {
		return spec;
	} else if(spec instanceof Red.RawRefinement) {
		return new Red.RawSetWord(spec.word.name);
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
		if(spec.toJsChar().match(/^[a-zA-Z_+\-*\/\.~`?!^&|=]$/)) {
			return new Red.RawSetWord(spec.toJsChar());
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
	_ctx:    Red.Context,
	value:   Red.RawSetWord,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push(value.name);
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawSetWord,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	builder.push(value.name + ":");
}