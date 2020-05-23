import * as Red from "../../red-types";
import RedActions from "../actions";

// TODO: make this all more accurate (and fix vector! ops since I already kinda did in integer.ts)

export function $compare(
	_ctx:   Red.Context,
	value1: Red.RawFloat,
	value2: Red.AnyType,
	op:     Red.ComparisonOp
): Red.CompareResult {
	if((op == Red.ComparisonOp.FIND || op == Red.ComparisonOp.STRICT_EQUAL) && !(value2 instanceof Red.RawFloat)) {
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
		throw new TypeError("Can't compare float! to " + Red.typeName(value2));
	}
}

// $$make

export function $$form(
	_ctx:   Red.Context,
	value:  Red.RawFloat,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(value.value.toString());
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.RawFloat,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, value, buffer, _.part);
}

export function $$add(
	ctx:   Red.Context,
	left:  Red.RawFloat,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger || right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value + right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value + right.value / 100);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawFloat(left.value + right.char);
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value + right.value).toFixed(2));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value + right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawVector) {
		if(Red.RawVector.isPercent(right.values)) {
			return new Red.RawVector(
				right.values
					.slice(right.index-1)
					.map((v: Red.RawPercent) => new Red.RawPercent(left.value * 100 + v.value))
			);
		} else if(Red.RawVector.isChar(right.values)) {
			return new Red.RawVector(
				right.values
					.slice(right.index-1)
					.map((v: Red.RawChar) => new Red.RawChar(left.value + v.char))
			);
		} else {
			return new Red.RawVector(
				(right.values as any)
					.slice(right.index-1)
					.map((v: any) => $$add(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't add float! with type " + Red.typeName(right));
	}
}

export function $$subtract(
	ctx:   Red.Context,
	left:  Red.RawFloat,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger || right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value - right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value - right.value / 100);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawFloat(left.value - right.char);
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value - right.value).toFixed(2));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value - right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawVector) {
		if(Red.RawVector.isPercent(right.values)) {
			return new Red.RawVector(
				right.values
					.slice(right.index-1)
					.map((v: Red.RawPercent) => new Red.RawPercent(left.value * 100 - v.value))
			);
		} else if(Red.RawVector.isChar(right.values)) {
			return new Red.RawVector(
				right.values
					.slice(right.index-1)
					.map((v: Red.RawChar) => new Red.RawChar(left.value - v.char))
			);
		} else {
			return new Red.RawVector(
				(right.values as any)
					.slice(right.index-1)
					.map((v: any) => $$subtract(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't subtract float! with type " + Red.typeName(right));
	}
}

export function $$multiply(
	ctx:   Red.Context,
	left:  Red.RawFloat,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger || right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value * right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value * (right.value / 100));
	} else if(right instanceof Red.RawChar) {
		return new Red.RawFloat(left.value * right.char);
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value * right.value).toFixed(2));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value * right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawVector) {
		if(Red.RawVector.isPercent(right.values)) {
			return new Red.RawVector(
				right.values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value * 100 * v.value))
			);
		} else if(Red.RawVector.isChar(right.values)) {
			return new Red.RawVector(
				right.values
					.slice(right.index-1)
					.map(v => new Red.RawChar(left.value * v.char))
			);
		} else {
			return new Red.RawVector(
				(right.values as any)
					.slice(right.index-1)
					.map((v: any) => $$multiply(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't multiply float! with type " + Red.typeName(right));
	}
}

export function $$divide(
	ctx:   Red.Context,
	left:  Red.RawFloat,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger || right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value / right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value / (right.value / 100));
	} else if(right instanceof Red.RawChar) {
		return new Red.RawFloat(left.value / right.char);
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value / right.value).toFixed(2));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value / right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawVector) {
		if(Red.RawVector.isPercent(right.values)) {
			return new Red.RawVector(
				right.values
					.slice(right.index-1)
					.map((v: Red.RawPercent) => new Red.RawPercent(left.value * 100 / v.value))
			);
		} else if(Red.RawVector.isChar(right.values)) {
			return new Red.RawVector(
				right.values
					.slice(right.index-1)
					.map((v: Red.RawChar) => new Red.RawChar(Math.floor(left.value / v.char)))
			);
		} else {
			return new Red.RawVector(
				(right.values as any)
					.slice(right.index-1)
					.map((v: any) => $$divide(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't divide float! with type " + Red.typeName(right));
	}
}

// ...