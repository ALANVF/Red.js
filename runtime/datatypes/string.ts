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
	} else { // Unsure if /only should be ignored
		str.values.push(...RedActions.$$form(ctx, value).values);
	}

	return str;
}