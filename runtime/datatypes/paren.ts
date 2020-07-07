import * as Red from "../../red-types";
import RedActions from "../actions";
import {tokenize} from "../../tokenizer";
import RedUtil from "../util";

export function $$make(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawParen {
	if(spec instanceof Red.RawInteger || spec instanceof Red.RawFloat) {
		return new Red.RawParen([]);
	} else if(Red.isAnyPath(spec)) {
		return new Red.RawParen(spec.current().path);
	} else if(Red.isAnyList(spec)) {
		return new Red.RawParen(spec.values.slice(spec.index-1));
	} else if(spec instanceof Red.Context || spec instanceof Red.RawObject) {
		return new Red.RawParen(RedUtil.Arrays.zip(
			spec.words.map(w => new Red.RawSetWord(w)),
			spec.values
		).flat())
	} else if(spec instanceof Red.RawMap) {
		return new Red.RawParen(RedUtil.Arrays.zip(spec.keys, spec.values).flat());
	} else if(spec instanceof Red.RawVector) {
		return new Red.RawParen(spec.toRedValues().slice(spec.index-1));
	} else {
		throw new TypeError("Cannot create a paren! from an instance of " + Red.typeName(spec));
	}
}

export function $$to(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawParen {
	if(Red.isAnyPath(spec)) {
		return new Red.RawParen(spec.current().path);
	} else if(Red.isAnyList(spec)) {
		return new Red.RawParen(spec.values.slice(spec.index-1));
	} else if(spec instanceof Red.Context || spec instanceof Red.RawObject) {
		return new Red.RawParen(RedUtil.Arrays.zip(
			spec.words.map(w => new Red.RawSetWord(w)),
			spec.values
		).flat())
	} else if(spec instanceof Red.RawMap) {
		return new Red.RawParen(RedUtil.Arrays.zip(spec.keys, spec.values).flat());
	} else if(spec instanceof Red.RawVector) {
		return new Red.RawParen(spec.toRedValues().slice(spec.index-1));
	} else if(spec instanceof Red.RawString) {
		return new Red.RawParen(tokenize(spec.toJsString()));
	} else if(spec instanceof Red.RawTypeset) {
		return new Red.RawParen([...spec.types]);
	} else {
		return new Red.RawParen([spec]);
	}
}

export function $$mold(
	ctx:    Red.Context,
	paren:  Red.RawParen,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const blk = paren.values.slice(paren.index-1);

	if(blk.length == 0) {
		buffer.push("()");
	} else {
		buffer.push("(");
		
		RedActions.valueSendAction("$$mold", ctx, blk[0], buffer, indent, _);

		for(const val of blk.slice(1)) {
			buffer.push(" ");
			RedActions.valueSendAction("$$mold", ctx, val, buffer, indent, _);
		}

		buffer.push(")");
	}

	return false;
}