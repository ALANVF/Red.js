import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

export function $compare(
	_ctx:   Red.Context,
	value1: Red.RawLogic,
	value2: Red.AnyType,
	op:     Red.ComparisonOp
): Red.CompareResult {
	if((op == Red.ComparisonOp.FIND || op == Red.ComparisonOp.STRICT_EQUAL) && !(value2 instanceof Red.RawLogic)) {
		return 1;
	}
	
	if(value2 instanceof Red.RawLogic && ![Red.ComparisonOp.GREATER, Red.ComparisonOp.GREATER_EQUAL, Red.ComparisonOp.LESSER, Red.ComparisonOp.LESSER_EQUAL].includes(op)) {
		return +value1.cond - +value2.cond as Red.CompareResult;
	} else {
		// supposed to do something else but this works for now I guess
		throw new TypeError("Can't compare integer! to " + Red.typeName(value2));
	}
}

// $$make

export function $$form(
	_ctx:    Red.Context,
	value:   Red.RawLogic,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push(value.cond.toString());
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawLogic,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	if(_.all === true) {
		builder.push("#[" + value.cond.toString() + "]")
	} else {
		builder.push(value.cond.toString());
	}
	
	return false;
}

export function $$and_t(
	_ctx:  Red.Context,
	left:  Red.RawLogic,
	right: Red.RawLogic
): Red.RawLogic {
	if(right instanceof Red.RawLogic) {
		return Red.RawLogic.from(left.cond && right.cond);
	} else {
		throw new TypeError("error!");
	}
}

export function $$complement(
	_ctx:  Red.Context,
	value: Red.RawLogic
): Red.RawLogic {
	return Red.RawLogic.from(!value.cond);
}

export function $$or_t(
	_ctx:  Red.Context,
	left:  Red.RawLogic,
	right: Red.RawLogic
): Red.RawLogic {
	if(right instanceof Red.RawLogic) {
		return Red.RawLogic.from(left.cond || right.cond);
	} else {
		throw new TypeError("error!");
	}
}

export function $$xor_t(
	_ctx:  Red.Context,
	left:  Red.RawLogic,
	right: Red.RawLogic
): Red.RawLogic {
	if(right instanceof Red.RawLogic) {
		return Red.RawLogic.from(left.cond != right.cond);
	} else {
		throw new TypeError("error!");
	}
}