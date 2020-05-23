import * as Red from "../../red-types";
import RedActions from "../actions";

export function $compare(
	ctx:    Red.Context,
	value1: Red.RawChar,
	value2: Red.AnyType,
	op:     Red.ComparisonOp
): Red.CompareResult {
	if((op == Red.ComparisonOp.FIND || op == Red.ComparisonOp.STRICT_EQUAL) && !(value2 instanceof Red.RawChar)) {
		return 1;
	}

	const cmp = (l: number, r: number) => l < r ? -1 : (l > r ? 1 : 0);
	
	if(value2 instanceof Red.RawInteger) {
		return cmp(value1.char, value2.value);
	} else if(value2 instanceof Red.RawChar) {
		if(op == Red.ComparisonOp.CASE_SORT || op == Red.ComparisonOp.STRICT_EQUAL || op == Red.ComparisonOp.SAME
		|| op == Red.ComparisonOp.GREATER || op == Red.ComparisonOp.GREATER_EQUAL || op == Red.ComparisonOp.LESSER
		|| op == Red.ComparisonOp.LESSER_EQUAL) {
			return cmp(value1.char, value2.char);
		} else {
			return cmp(value1.lowerChar, value2.lowerChar);
		}
	} else {
		return RedActions.valueSendAction("$compare", ctx, value2, value1, Red.ComparisonOp.flip(op));
	}
}

// $$make

// $$to

export function $$form(
	_ctx:   Red.Context,
	value:  Red.RawChar,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(value.toJsChar());
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawChar,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push(`#"${value.toRedChar()}"`);
	return true;
}

export function $$add(
	_ctx:  Red.Context,
	left:  Red.RawChar,
	right: Red.AnyType
): Red.RawChar|Red.RawVector {
	if(right instanceof Red.RawInteger) {
		if(right.value < -left.char) {
			throw new Error("Underflow error!");
		} else {
			return new Red.RawChar(left.char + right.value);
		}
	} else if(right instanceof Red.RawChar) {
		return new Red.RawChar(left.char + right.char);
	} else if(right instanceof Red.RawFloat) {
		const value = Math.floor(right.value);

		if(value < -left.char) {
			throw new Error("Underflow error!");
		} else {
			return new Red.RawChar(left.char + value);
		}
	} else if(right instanceof Red.RawVector) {
		Red.todo();
	} else {
		throw new TypeError("Can't add char! with type " + Red.typeName(right));
	}
}

export function $$subtract(
	_ctx:  Red.Context,
	left:  Red.RawChar,
	right: Red.AnyType
): Red.RawChar|Red.RawInteger|Red.RawVector {
	if(right instanceof Red.RawInteger) {
		if(right.value > left.char) {
			throw new Error("Underflow error!");
		} else {
			return new Red.RawChar(left.char - right.value);
		}
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.char - right.char);
	} else if(right instanceof Red.RawFloat) {
		const value = Math.floor(right.value);
		
		if(value > left.char) {
			throw new Error("Underflow error!");
		} else {
			return new Red.RawChar(left.char + value);
		}
	} else if(right instanceof Red.RawVector) {
		Red.todo();
	} else {
		throw new TypeError("Can't subtract char! with type " + Red.typeName(right));
	}
}