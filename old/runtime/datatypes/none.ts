import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

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
	_ctx:    Red.Context,
	_value:  Red.RawNone,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push("none");
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawNone,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	if(_.all !== undefined) {
		builder.push("#[none]");
		false;
	} else {
		$$form(ctx, value, builder, _.part);
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