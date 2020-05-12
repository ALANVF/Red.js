import * as Red from "../../red-types";
import RedActions from "../actions";

// $$make

export function $$form(
	_ctx: Red.Context,
	str: Red.RawString,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push('"');
	buffer.push(str.toJsString());
	buffer.push('"');

	return false;
}

export function $$mold(
	_ctx: Red.Context,
	str: Red.RawString,
	buffer: string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const str_ = str.values.slice(str.index-1);

	if(str_.length == 0) {
		buffer.push('""');
	} else {
		buffer.push('"');
		buffer.push(str_.map(ch => ch.char).join(""));
		buffer.push('"');
	}

	return false;
}

// ...

export function $$append(
	ctx:    Red.Context,
	series: Red.RawString,
	value:  Red.AnyType,
	_: RedActions.AppendOptions = {}
): Red.RawString {
	if(_.part !== undefined || _.dup !== undefined) {
		Red.todo();
	} else if(value instanceof Red.RawChar) {
		series.values.push(value);
	} else if(value instanceof Red.RawString) {
		series.values.push(...value.values.slice(value.index - 1));
	} else { // Unsure if /only should be ignored
		series.values.push(...RedActions.$$form(ctx, value).values);
	}

	return series;
}