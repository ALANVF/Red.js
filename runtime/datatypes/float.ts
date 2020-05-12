import * as Red from "../../red-types";
import RedActions from "../actions";

// TODO: make this all more accurate (and fix vector! ops since I already kinda did in integer.ts)

export function $compare(
	_ctx: Red.Context,
	value1: Red.RawFloat,
	value2: Red.AnyType,
	op: Red.ComparisonOp
): Red.CompareResult {
	if((op == Red.ComparisonOp.FIND || op == Red.ComparisonOp.STRICT_EQUAL) && !(value2 instanceof Red.RawFloat)) {
		return 1;
	}
	
	if(value2 instanceof Red.RawInteger || value2 instanceof Red.RawFloat || value2 instanceof Red.RawMoney) {
		return value1.value < value2.value ? -1 : value1.value > value2.value ? 1 : 0;
	} else if(value2 instanceof Red.RawChar) {
		const l = value1.value;
		const r = value2.char.charCodeAt(0);
		return l<r?-1:l>r?1:0;
	} else if(value2 instanceof Red.RawPercent) {
		const l = value1.value;
		const r = value2.value/100;
		return l<r?-1:l>r?1:0;
	} else if(value2 instanceof Red.RawTime) {
		const l = value1.value;
		const r = value2.toNumber();
		return l<r?-1:l>r?1:0;
	} else {
		// supposed to do something else but this works for now I guess
		throw TypeError("Can't compare float! to " + Red.TYPE_NAME(value2));
	}
}

// $$make

export function $$form(
	_ctx: Red.Context,
	value: Red.RawFloat,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(value.value.toString());
	return false;
}

export function $$mold(
	ctx: Red.Context,
	value: Red.RawFloat,
	buffer: string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, value, buffer, _.part);
}

export function $$add(
	ctx: Red.Context,
	left: Red.RawFloat,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value + right.value);
	} else if(right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value + right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value + right.value / 100);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawFloat(left.value + right.char.charCodeAt(0));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value + right.value).toFixed(2));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value + right.toNumber());
	} /*else if(right instanceof Red.RawDate) {

	}*/ else if(right instanceof Red.RawVector) {
		if(right.values.every((v: any) => v instanceof Red.RawPercent)) {
			return new Red.RawVector(
				(right.values as Red.RawPercent[])
					.slice(right.index-1)
					.map((v: Red.RawPercent) => new Red.RawPercent(left.value * 100 + v.value))
			);
		} else if(right.values.every((v: any) => v instanceof Red.RawChar)) {
			return new Red.RawVector(
				(right.values as Red.RawChar[])
					.slice(right.index-1)
					.map((v: Red.RawChar) => new Red.RawChar(String.fromCharCode(left.value * 100 + v.char.charCodeAt(0))))
			);
		} else {
			return new Red.RawVector(
				(right.values as any)
					.slice(right.index-1)
					.map((v: any) => $$add(ctx, left, v))
			);
		}
	} else {
		throw TypeError("Can't add float! with type " + Red.TYPE_NAME(right));
	}
}

export function $$subtract(
	ctx: Red.Context,
	left: Red.RawFloat,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value - right.value);
	} else if(right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value - right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value - right.value / 100);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawFloat(left.value - right.char.charCodeAt(0));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value - right.value).toFixed(2));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value - right.toNumber());
	} /*else if(right instanceof Red.RawDate) {

	}*/ else if(right instanceof Red.RawVector) {
		if(right.values.every((v: any) => v instanceof Red.RawPercent)) {
			return new Red.RawVector(
				(right.values as Red.RawPercent[])
					.slice(right.index-1)
					.map((v: Red.RawPercent) => new Red.RawPercent(left.value * 100 - v.value))
			);
		} else if(right.values.every((v: any) => v instanceof Red.RawChar)) {
			return new Red.RawVector(
				(right.values as Red.RawChar[])
					.slice(right.index-1)
					.map((v: Red.RawChar) => new Red.RawChar(String.fromCharCode(left.value * 100 - v.char.charCodeAt(0))))
			);
		} else {
			return new Red.RawVector(
				(right.values as any)
					.slice(right.index-1)
					.map((v: any) => $$subtract(ctx, left, v))
			);
		}
	} else {
		throw TypeError("Can't subtract float! with type " + Red.TYPE_NAME(right));
	}
}

export function $$multiply(
	ctx: Red.Context,
	left: Red.RawFloat,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value * right.value);
	} else if(right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value * right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value * (right.value / 100));
	} else if(right instanceof Red.RawChar) {
		return new Red.RawFloat(left.value * right.char.charCodeAt(0));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value * right.value).toFixed(2));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value * right.toNumber());
	} /*else if(right instanceof Red.RawDate) {

	}*/ else if(right instanceof Red.RawVector) {
		if(right.values.every((v: any) => v instanceof Red.RawPercent)) {
			return new Red.RawVector(
				(right.values as Red.RawPercent[])
					.slice(right.index-1)
					.map((v: Red.RawPercent) => new Red.RawPercent(left.value * 100 * v.value))
			);
		} else if(right.values.every((v: any) => v instanceof Red.RawChar)) {
			return new Red.RawVector(
				(right.values as Red.RawChar[])
					.slice(right.index-1)
					.map((v: Red.RawChar) => new Red.RawChar(String.fromCharCode(left.value * 100 * v.char.charCodeAt(0))))
			);
		} else {
			return new Red.RawVector(
				(right.values as any)
					.slice(right.index-1)
					.map((v: any) => $$multiply(ctx, left, v))
			);
		}
	} else {
		throw TypeError("Can't multiply float! with type " + Red.TYPE_NAME(right));
	}
}

export function $$divide(
	ctx: Red.Context,
	left: Red.RawFloat,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value / right.value);
	} else if(right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value / right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value / (right.value / 100));
	} else if(right instanceof Red.RawChar) {
		return new Red.RawFloat(left.value / right.char.charCodeAt(0));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value / right.value).toFixed(2));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value / right.toNumber());
	} /*else if(right instanceof Red.RawDate) {

	}*/ else if(right instanceof Red.RawVector) {
		if(right.values.every((v: any) => v instanceof Red.RawPercent)) {
			return new Red.RawVector(
				(right.values as Red.RawPercent[])
					.slice(right.index-1)
					.map((v: Red.RawPercent) => new Red.RawPercent(left.value * 100 / v.value))
			);
		} else if(right.values.every((v: any) => v instanceof Red.RawChar)) {
			return new Red.RawVector(
				(right.values as Red.RawChar[])
					.slice(right.index-1)
					.map((v: Red.RawChar) => new Red.RawChar(String.fromCharCode(Math.floor(left.value * 100 / v.char.charCodeAt(0)))))
			);
		} else {
			return new Red.RawVector(
				(right.values as any)
					.slice(right.index-1)
					.map((v: any) => $$divide(ctx, left, v))
			);
		}
	} else {
		throw TypeError("Can't divide float! with type " + Red.TYPE_NAME(right));
	}
}

// ...