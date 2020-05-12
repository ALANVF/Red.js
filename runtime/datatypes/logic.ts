import * as Red from "../../red-types";
import RedActions from "../actions";

export function $compare(
	_ctx: Red.Context,
	value1: Red.RawLogic,
	value2: Red.AnyType,
	op: Red.ComparisonOp
): Red.CompareResult {
	if((op == Red.ComparisonOp.FIND || op == Red.ComparisonOp.STRICT_EQUAL) && !(value2 instanceof Red.RawLogic)) {
		return 1;
	}
	
	if(value2 instanceof Red.RawLogic && ![Red.ComparisonOp.GREATER, Red.ComparisonOp.GREATER_EQUAL, Red.ComparisonOp.LESSER, Red.ComparisonOp.LESSER_EQUAL].includes(op)) {
		return +value1.cond - +value2.cond as Red.CompareResult;
	} else {
		// supposed to do something else but this works for now I guess
		throw TypeError("Can't compare integer! to " + Red.TYPE_NAME(value2));
	}
}

// $$make

export function $$form(
	_ctx: Red.Context,
	value: Red.RawLogic,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(value.cond.toString());
	return false;
}

export function $$mold(
	_ctx: Red.Context,
	value: Red.RawLogic,
	buffer: string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push("#[" + value.cond.toString() + "]")
	return false;
}

export function $$and_t(
	_ctx: Red.Context,
	left: Red.RawLogic,
	right: Red.RawLogic
): Red.RawLogic {
	if(right instanceof Red.RawLogic) {
		return new Red.RawLogic(left.cond && right.cond);
	} else {
		throw TypeError("error!");
	}
}

export function $$complement(
	_ctx: Red.Context,
	value: Red.RawLogic
): Red.RawLogic {
	return new Red.RawLogic(!value.cond);
}

export function $$or_t(
	_ctx: Red.Context,
	left: Red.RawLogic,
	right: Red.RawLogic
): Red.RawLogic {
	if(right instanceof Red.RawLogic) {
		return new Red.RawLogic(left.cond || right.cond);
	} else {
		throw TypeError("error!");
	}
}

export function $$xor_t(
	_ctx: Red.Context,
	left: Red.RawLogic,
	right: Red.RawLogic
): Red.RawLogic {
	if(right instanceof Red.RawLogic) {
		return new Red.RawLogic(!!(+left.cond ^ +right.cond));
	} else {
		throw TypeError("error!");
	}
}