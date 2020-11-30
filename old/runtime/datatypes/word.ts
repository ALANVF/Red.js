import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

function symbol(value: Red.RawAllWord): string {
	if(Red.isAnyWord(value)) {
		return value.name;
	} else if(value instanceof Red.RawIssue) {
		return value.value;
	} else if(value.name instanceof Red.RawWord) {
		return value.name.name;
	} else {
		return value.name.value.toString();
	}
}

export function $compare(
	_ctx:   Red.Context,
	value1: Red.RawAllWord,
	value2: Red.AnyType,
	op:     Red.ComparisonOp
): Red.CompareResult {
	if(!Red.isAllWord(value2)) {
		return -2;
	}

	switch(op) {
		case Red.ComparisonOp.EQUAL:
		case Red.ComparisonOp.NOT_EQUAL:
		case Red.ComparisonOp.FIND:
			return symbol(value1).toLowerCase() != symbol(value2).toLowerCase();

		case Red.ComparisonOp.SAME:
		case Red.ComparisonOp.STRICT_EQUAL:
			return value1.constructor !== value2.constructor || symbol(value1) != symbol(value2);

		case Red.ComparisonOp.STRICT_EQUAL_WORD:
			if((value1 instanceof Red.RawWord && value2 instanceof Red.RawLitWord) || (value1 instanceof Red.RawLitWord && value2 instanceof Red.RawWord)) {
				return symbol(value1) != symbol(value2);
			} else {
				return value1.constructor !== value2.constructor || symbol(value1) != symbol(value2);
			}
		
		default:
			// uh whatever this is supposed to do
			/*
			default [
				s: GET_BUFFER(symbols)
				str1: as red-string! s/offset + arg1/symbol - 1
				str2: as red-string! s/offset + arg2/symbol - 1
				res: string/equal? str1 str2 op no
			]
			*/
			Red.todo();
	}
}

// $$make

export function $$to(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawWord {
	if(spec instanceof Red.RawDatatype) {
		return new Red.RawWord(spec.name);
	} else if(spec instanceof Red.RawWord) {
		return spec;
	} else if(spec instanceof Red.RawGetWord || spec instanceof Red.RawSetWord || spec instanceof Red.RawLitWord || spec instanceof Red.RawRefinement) {
		return spec.word;
	} else if(spec instanceof Red.RawIssue) {
		if(spec.value.match(/^['\d]|[,]/)) {
			throw new Error("error");
		} else {
			return new Red.RawWord(spec.value);
		}
	} else if(spec instanceof Red.RawString) {
		const str = spec.toJsString();
		if(str.match(/[\s$%,\/\\()\[\]{}@<>]|^['\d]/)) {
			throw new Error("error");
		} else {
			return new Red.RawWord(str);
		}
	} else if(spec instanceof Red.RawChar) {
		if(spec.toJsChar().match(/^[a-zA-Z_+\-*\/\.~`?!^&|=]$/)) {
			return new Red.RawWord(spec.toJsChar());
		} else {
			throw new Error("error");
		}
	} else if(spec instanceof Red.RawLogic) {
		return new Red.RawWord(spec.cond ? "true" : "false");
	} else {
		throw new Error("error");
	}
}

export function $$form(
	_ctx:    Red.Context,
	value:   Red.RawWord,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push(value.name);
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawWord,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	$$form(ctx, value, builder, _.part);
}