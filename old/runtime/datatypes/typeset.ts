import * as Red from "../../red-types";
import RedNatives from "../natives";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

// $compare

export function $$make(
	ctx:    Red.Context,
	_proto: Red.AnyType,
	spec:   Red.RawBlock|Red.RawTypeset
): Red.RawTypeset {
	if(spec instanceof Red.RawTypeset) {
		return spec;
	} else {
		const out: Red.RawDatatype[] = [];

		for(let value of spec.current().values) {
			if(value instanceof Red.RawWord) {
				value = RedNatives.$$get(ctx, value);
			}

			if(value instanceof Red.RawDatatype) {
				out.push(value);
			} else if(value instanceof Red.RawTypeset) {
				out.push(...value.types);
			} else {
				throw new Error("error!");
			}
		}
		
		return new Red.RawTypeset(out);
	}
}

export function $$form(
	_ctx:    Red.Context,
	value:   Red.RawTypeset,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push("make typeset! [");
	builder.push(value.types.map(type => type.name).join(" "));
	builder.push("]");
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawTypeset,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
) {
	$$form(ctx, value, builder, _.part);
}

export function $$and_t(
	_ctx:  Red.Context,
	left:  Red.RawTypeset,
	right: Red.AnyType
): Red.RawTypeset {
	if(right instanceof Red.RawTypeset) {
		return new Red.RawTypeset(
			left.types.filter(type1 =>
				right.types.find(type2 => type1.equals(type2)) !== undefined
			)
		);
	} else if(right instanceof Red.RawDatatype) {
		return new Red.RawTypeset(left.types.filter(type => type.equals(right)));
	} else {
		throw new TypeError("error!");
	}
}

// $$complement

// TODO: FINISH
export function $$or_t(
	_ctx:  Red.Context,
	left:  Red.RawTypeset,
	right: Red.AnyType
): Red.RawTypeset {
	if(right instanceof Red.RawTypeset) {
		return new Red.RawTypeset([
			...left.types,
			...right.types.filter(type1 =>
				left.types.find(type2 => type1.equals(type2)) === undefined
			)
		]);
	} else if(right instanceof Red.RawDatatype) {
		if(left.types.find(type => type.equals(right)) === undefined) {
			return new Red.RawTypeset([...left.types, right]);
		} else {
			return left;
		}
	} else {
		throw new TypeError("error!");
	}
}

export function $$xor_t(
	_ctx:  Red.Context,
	left:  Red.RawTypeset,
	right: Red.AnyType
): Red.RawTypeset {
	if(right instanceof Red.RawTypeset) {
		return new Red.RawTypeset([
			...left.types.filter(type1 =>
				right.types.find(type2 => type1.equals(type2)) === undefined
			),
			...right.types.filter(type1 =>
				left.types.find(type2 => type1.equals(type2)) === undefined
			)
		]);
	} else if(right instanceof Red.RawDatatype) {
		const index = left.types.findIndex(type => type.equals(right));
		if(index == -1) {
			return left;
		} else {
			return new Red.RawTypeset(left.types.filter((_, i) => i != index));
		}
	} else {
		throw new TypeError("error!");
	}
}

export function $$find(
	_ctx:    Red.Context,
	typeset: Red.RawTypeset,
	value:   Red.AnyType,
	_: RedActions.FindOptions = {}
): Red.RawLogic {
	if(value instanceof Red.RawDatatype) {
		return Red.RawLogic.from(typeset.types.some(dt => dt.equals(value)));
	} else {
		throw new TypeError(`${Red.typeName(value)} is not allowed here!`);
	}
}