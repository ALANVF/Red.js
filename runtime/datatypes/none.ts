import * as Red from "../../red-types";
import RedActions from "../actions";

/* Native functions */
export function $compare(
	_ctx:    Red.Context,
	_value1: Red.RawNone,
	value2:  Red.AnyType,
	op:      Red.ComparisonOp
): Red.CompareResult {
	if(value2 instanceof Red.RawNone) {
		switch(op) {
			case Red.ComparisonOp.EQUAL:
			case Red.ComparisonOp.SAME:
			case Red.ComparisonOp.FIND:
			case Red.ComparisonOp.STRICT_EQUAL:
			case Red.ComparisonOp.NOT_EQUAL:
			case Red.ComparisonOp.SORT:
			case Red.ComparisonOp.CASE_SORT:
				return 0;
		}
	}

	return -2;
}

/* Actions */
export function $$make(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	_spec:  Red.AnyType
): Red.RawNone {
	return Red.RawNone.none;
}

export function $$to(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	_spec:  Red.AnyType
): Red.RawNone {
	return Red.RawNone.none;
}

export function $$form(
	_ctx:   Red.Context,
	_value: Red.RawNone,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push("none");
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawNone,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	if(_.all !== undefined) {
		buffer.push("#[none]");
		return false;
	} else {
		return $$form(ctx, value, buffer, _.part);
	}
}

// ...

export function $$clear(
	_ctx: Red.Context,
	none: Red.RawNone
): Red.RawNone {
	return none;
}

// ...

export function $$remove(
	_ctx: Red.Context,
	none: Red.RawNone,
	_: RedActions.RemoveOptions = {}
): Red.RawNone {
	return none;
}