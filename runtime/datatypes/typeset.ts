import * as Red from "../../red-types";
import RedNatives from "../natives";
import RedActions from "../actions";

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
	_ctx:   Red.Context,
	value:  Red.RawTypeset,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push("make typeset! [");
	buffer.push(value.types.map(type => type.name).join(" "));
	buffer.push("]");
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawTypeset,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, value, buffer, _.part);
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

// $$find