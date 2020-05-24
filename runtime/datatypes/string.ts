import * as Red from "../../red-types";
import RedActions from "../actions";

// $$make

export function $$form(
	_ctx:   Red.Context,
	str:    Red.RawString,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(str.toJsString());
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	str:     Red.RawString,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	if(str.length == 0) {
		buffer.push('""');
	} else {
		const chars = str.toRedString();
		
		if(chars.includes('^"')) {
			buffer.push("{");
			buffer.push(chars.replace(/\^"/g, '"'));
			buffer.push("}");
		} else {
			buffer.push('"');
			buffer.push(chars);
			buffer.push('"');
		}
	}

	return false;
}

// ...

export function $$copy(
	_ctx: Red.Context,
	str:  Red.RawString,
	_: RedActions.CopyOptions = {}
): Red.RawString {
	if(_.part !== undefined) {
		Red.todo();
	} else if(str.index == 1) {
		return new Red.RawString([...str.values]);
	} else {
		return new Red.RawString(str.values.slice(str.index - 1));
	}
}

export function $$append(
	ctx:   Red.Context,
	str:   Red.RawString,
	value: Red.AnyType,
	_: RedActions.AppendOptions = {}
): Red.RawString {
	if(_.part !== undefined || _.dup !== undefined) {
		Red.todo();
	} else if(value instanceof Red.RawChar) {
		str.values.push(value);
	} else if(value instanceof Red.RawString) {
		str.values.push(...value.current().values);
	} else if(value instanceof Red.RawBlock) {
		for(const elem of value.current().values) {
			str.values.push(...RedActions.$$form(ctx, elem).values);
		}
	} else { // Unsure if /only should be ignored
		str.values.push(...RedActions.$$form(ctx, value).values);
	}

	return str;
}

export function $$poke(
	_ctx:  Red.Context,
	str:   Red.RawString,
	index: Red.AnyType,
	value: Red.AnyType
): Red.RawChar|Red.RawInteger {
	if(!(index instanceof Red.RawInteger)) {
		throw new TypeError("error!");
	}
	
	if(index.value < 1 || index.value > str.length) {
		throw new RangeError("error!");
	} else if(value instanceof Red.RawChar) {
		return str.values[(str.index - 1) + (index.value - 1)] = value;
	} else if(value instanceof Red.RawInteger) {
		if(value.value < 0) {
			throw new RangeError("Out of bounds!");
		} else {
			str.values[(str.index - 1) + (index.value - 1)] = new Red.RawChar(value.value);
			return value;
		}
	} else {
		throw new TypeError("error!");
	}
}