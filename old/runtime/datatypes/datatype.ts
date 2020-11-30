import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

export function $compare(
	_ctx:   Red.Context,
	value1: Red.RawDatatype,
	value2: Red.AnyType,
	op:     Red.ComparisonOp
): Red.CompareResult {
	switch(op) {
		case Red.ComparisonOp.EQUAL:
		case Red.ComparisonOp.FIND:
		case Red.ComparisonOp.SAME:
		case Red.ComparisonOp.STRICT_EQUAL:
		case Red.ComparisonOp.NOT_EQUAL: {
			if(value2 instanceof Red.RawDatatype && value1.equals(value2)) {
				return 0;
			} else {
				return 1;
			}
		}

		default: {
			return -2;
		}
	}
}

/* Actions */

// $$make

// $$to

export function $$form(
	_ctx:   Red.Context,
	value:  Red.RawDatatype,
	builder: StringBuilder,
	_part?: number
) {
	builder.push(value.name);
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawDatatype,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	if(_.all !== undefined) {
		builder.push("#[datatype! " + value.name + "]");
	} else {
		return $$form(ctx, value, builder, _.part);
	}
}