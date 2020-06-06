import * as Red from "../../red-types";
import RedActions from "../actions";

export function $compare(
	_ctx:   Red.Context,
	value1: Red.RawInteger,
	value2: Red.AnyType,
	op:     Red.ComparisonOp
): Red.CompareResult {
	if((op == Red.ComparisonOp.FIND || op == Red.ComparisonOp.STRICT_EQUAL) && !(value2 instanceof Red.RawInteger)) {
		return 1;
	}

	const cmp = (l: number, r: number) => l < r ? -1 : (l > r ? 1 : 0);
	
	if(value2 instanceof Red.RawInteger || value2 instanceof Red.RawFloat || value2 instanceof Red.RawMoney) {
		return cmp(value1.value, value2.value);
	} else if(value2 instanceof Red.RawChar) {
		return cmp(value1.value, value2.char);
	} else if(value2 instanceof Red.RawPercent) {
		return cmp(value1.value, value2.value/100);
	} else if(value2 instanceof Red.RawTime) {
		return cmp(value1.value, value2.toNumber());
	} else {
		// supposed to do something else but this works for now I guess
		throw new TypeError("Can't compare integer! to " + Red.typeName(value2));
	}
}

// $$make

export function $$form(
	_ctx:   Red.Context,
	value:  Red.RawInteger,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(value.value.toString());
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawInteger,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, value, buffer, _.part);
}

export function $$absolute(
	_ctx:  Red.Context,
	value: Red.RawInteger
): Red.RawInteger {
	return new Red.RawInteger(Math.abs(value.value));
}

export function $$add(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value + right.value);
	} else if(right instanceof Red.RawFloat || right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value + right.value);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value + right.char);
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value + right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(left.value + right.x, left.value + right.y);
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value + right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map(v => left.value + v));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value + v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(left.value + v.char))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$add(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't add integer! with type " + Red.typeName(right));
	}
}

export function $$subtract(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value - right.value);
	} else if(right instanceof Red.RawFloat || right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value - right.value);;
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value - right.char);
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value - right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(left.value - right.x, left.value - right.y);
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value - right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map(v => left.value - v));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value - v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(left.value - v.char))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$subtract(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't subtract integer! with type " + Red.typeName(right));
	}
}

export function $$multiply(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value * right.value);
	} else if(right instanceof Red.RawFloat || right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value * right.value);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value * right.char);
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value * right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(left.value * right.x, left.value * right.y);
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value * right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map(v => left.value * v));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value * v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(left.value * v.char))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$multiply(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't multiply integer! with type " + Red.typeName(right));
	}
}

export function $$divide(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(Math.floor(left.value / right.value));
	} else if(right instanceof Red.RawFloat || right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value / right.value);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(Math.floor(left.value / right.char));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value / right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(Math.floor(left.value / right.x), Math.floor(left.value / right.y));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(Math.floor(left.value / right.toNumber()));
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map(v => Math.floor(left.value / v)));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value / v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(Math.floor(left.value / v.char)))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$divide(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't divide integer! with type " + Red.typeName(right));
	}
}

export function $$remainder(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value % right.value);
	} else if(right instanceof Red.RawFloat || right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value % right.value);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value % right.char);
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value % right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(left.value % right.x, left.value % right.y);
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value % right.toNumber());
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map(v => left.value % v));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value % v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(left.value % v.char))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$remainder(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't get the remainder of integer! with type " + Red.typeName(right));
	}
}

export function $$power(
	_ctx:     Red.Context,
	value:    Red.RawInteger,
	exponent: Red.RawInteger|Red.RawFloat
): Red.RawNumber {
	if(exponent instanceof Red.RawInteger && exponent.value >= 0) {
		return new Red.RawInteger(value.value ** exponent.value);
	} else {
		return new Red.RawFloat(value.value ** exponent.value);
	}
}

export function $$negate(
	_ctx:  Red.Context,
	value: Red.RawInteger
): Red.RawInteger {
	return new Red.RawInteger(-value.value);
}

// ...

export function $$and_t(
	_ctx:  Red.Context,
	left:  Red.RawInteger,
	right: Red.RawInteger|Red.RawChar|Red.RawPair|Red.RawVector|Red.RawTuple
): Red.RawInteger|Red.RawPair|Red.RawVector|Red.RawTuple {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value & right.value);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value & right.char);
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(left.value & right.x, left.value & right.y);
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);

		if(Red.RawVector.isInteger(values)) {
			return new Red.RawVector(values.map(int => new Red.RawInteger(left.value & int.value)));
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(values.map(ch => new Red.RawChar(left.value & ch.char)));
		} else {
			throw new Error("error!");
		}
	} else {
		return new Red.RawTuple(right.values.map(int => left.value & int));
	}
}

export function $$complement(
	_ctx:  Red.Context,
	value: Red.RawInteger
): Red.RawInteger {
	return new Red.RawInteger(~value.value);
}

export function $$or_t(
	_ctx:  Red.Context,
	left:  Red.RawInteger,
	right: Red.RawInteger|Red.RawChar|Red.RawPair|Red.RawVector|Red.RawTuple
): Red.RawInteger|Red.RawPair|Red.RawVector|Red.RawTuple {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value | right.value);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value | right.char);
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(left.value | right.x, left.value | right.y);
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);

		if(Red.RawVector.isInteger(values)) {
			return new Red.RawVector(values.map(int => new Red.RawInteger(left.value | int.value)));
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(values.map(ch => new Red.RawChar(left.value | ch.char)));
		} else {
			throw new Error("error!");
		}
	} else {
		return new Red.RawTuple(right.values.map(int => left.value | int));
	}
}

export function $$xor_t(
	_ctx:  Red.Context,
	left:  Red.RawInteger,
	right: Red.RawInteger|Red.RawChar|Red.RawPair|Red.RawVector|Red.RawTuple
): Red.RawInteger|Red.RawPair|Red.RawVector|Red.RawTuple {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value ^ right.value);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value ^ right.char);
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(left.value ^ right.x, left.value ^ right.y);
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);

		if(Red.RawVector.isInteger(values)) {
			return new Red.RawVector(values.map(int => new Red.RawInteger(left.value ^ int.value)));
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(values.map(ch => new Red.RawChar(left.value ^ ch.char)));
		} else {
			throw new Error("error!");
		}
	} else {
		return new Red.RawTuple(right.values.map(int => left.value ^ int));
	}
}