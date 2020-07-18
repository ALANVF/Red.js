import * as Red from "../../red-types";
import RedActions from "../actions";
import {$$skip} from "./series";
import {StringBuilder} from "../../helper-types";

function stringifyArg(
	ctx:   Red.Context,
	value: Red.AnyType
): Red.RawChar[] {
	if(value instanceof Red.RawChar) {
		return [value];
	} else if(value instanceof Red.RawString) {
		return value.values.slice(value.index - 1);
	} else if(Red.isAnyList(value)) {
		return (<Red.RawAnyList>value).current().values.flatMap(elem =>
			RedActions.$$form(ctx, elem).values
		);
	} else if(value instanceof Red.RawFile) {
		return [...value.current().name.ref].map(s => new Red.RawChar(s.charCodeAt(0)));
	} else {
		return RedActions.$$form(ctx, value).values;
	}
}

/* Actions */
export function $compare(
	ctx:    Red.Context,
	value1: Red.RawString,
	value2: Red.AnyType,
	op:     Red.ComparisonOp
): Red.CompareResult {
	if(
		value1.constructor !== value2.constructor
		&&
		(
			!Red.isAnyString(value2)
			||
			(
				op != Red.ComparisonOp.EQUAL
				&&
				op != Red.ComparisonOp.NOT_EQUAL
			)
		)
	) {
		return RedActions.valueSendAction("$compare", ctx, value2, value1, Red.ComparisonOp.flip(op));
	} else {
		const same = value1 === value2;
		
		if(op == Red.ComparisonOp.SAME) {
			return same ? 0 : -1;
		} else if(same && (op == Red.ComparisonOp.EQUAL || op == Red.ComparisonOp.FIND || op == Red.ComparisonOp.STRICT_EQUAL || op == Red.ComparisonOp.NOT_EQUAL)) {
			return 0;
		} else {
			let other: string;
			
			if(value2 instanceof Red.RawString) {
				const cmp = (l: string, r: string) =>
					(l < r || l.length < r.length)
						? -1
						: (l > r || l.length > r.length)
							? 1
							: 0;
				
				other = value2.toJsString();
				
				if(op == Red.ComparisonOp.CASE_SORT || op == Red.ComparisonOp.STRICT_EQUAL || op == Red.ComparisonOp.GREATER
				|| op == Red.ComparisonOp.GREATER_EQUAL || op == Red.ComparisonOp.LESSER || op == Red.ComparisonOp.LESSER_EQUAL) {
					return cmp(value1.toJsString(), other);
				} else {
					return cmp(value1.toJsString().toLowerCase(), other.toLowerCase());
				}
			} else if(op == Red.ComparisonOp.EQUAL || op == Red.ComparisonOp.NOT_EQUAL) {
				if(value2 instanceof Red.RawFile) {
					other = value2.name.ref.slice(value2.index - 1);
				} else if(value2 instanceof Red.RawUrl) {
					other = value2.url.ref.slice(value2.index - 1);
				} else if(value2 instanceof Red.RawEmail) {
					other = (value2.email.ref).slice(value2.index - 1);
				} else if(value2 instanceof Red.RawTag) {
					other = value2.tag.ref.slice(value2.index - 1);
				} else {
					throw new Error("error!");
				}
				
				return value1.toJsString().toLowerCase() == other.toLowerCase() ? 0 : -1;
			} else {
				return -2;
			}
		}
	}
}

// $$make

export function $$form(
	_ctx:    Red.Context,
	str:     Red.RawString,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push(str.toJsString());
}

export function $$mold(
	_ctx:    Red.Context,
	str:     Red.RawString,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	if(str.length == 0) {
		builder.push('""');
	} else {
		const chars = str.toRedString();
		
		if(chars.includes('^"')) {
			builder.push("{");
			builder.push(chars.replace(/\^"/g, '"'));
			builder.push("}");
		} else {
			builder.push('"');
			builder.push(chars);
			builder.push('"');
		}
	}
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
	const addChars = stringifyArg(ctx, value);
	
	if(_.dup !== undefined) {
		for(let i = 0; i < _.dup; i++) {
			str.values.push(...addChars);
		}
	} else if(_.part !== undefined) {
		str.values.push(...addChars.slice(0, _.part));
	} else {
		str.values.push(...addChars);
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

// ...

export function $$insert(
	ctx:   Red.Context,
	str:   Red.RawString,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {}
): Red.RawString {
	const index = str.index - 1;
	const addChars = stringifyArg(ctx, value);
	let offset = 0;
	
	if(_.dup !== undefined) {
		const dups = [];
		
		for(let i = 0; i < _.dup; i++) {
			dups.push(...addChars);
		}
		
		str.values.splice(index, 0, ...dups);
		offset += dups.length;
	} else if(_.part !== undefined) {
		str.values.splice(index, 0, ...addChars.slice(0, _.part));
		offset += _.part;
	} else {
		str.values.splice(index, 0, ...addChars);
		offset += addChars.length;
	}

	return $$skip(ctx, str, offset);
}

export function $$change(
	ctx:   Red.Context,
	str:   Red.RawString,
	value: Red.AnyType,
	_: RedActions.ChangeOptions = {}
): Red.RawString {
	const index = str.index - 1;
	const addChars = stringifyArg(ctx, value);
	let offset = 0;
	
	if(_.dup !== undefined) {
		const dups = [];
		
		for(let i = 0; i < _.dup; i++) {
			dups.push(...addChars);
		}
		
		str.values.splice(index, dups.length, ...dups);
		offset += dups.length;
	} else if(_.part !== undefined) {
		str.values.splice(index, _.part, ...addChars.slice(0, _.part));
		offset += _.part;
	} else {
		str.values.splice(index, addChars.length, ...addChars);
		offset += addChars.length;
	}

	return $$skip(ctx, str, offset);
}