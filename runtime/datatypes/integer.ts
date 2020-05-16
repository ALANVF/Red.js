import * as Red from "../../red-types";
import RedActions from "../actions";

export function $compare(
	_ctx: Red.Context,
	value1: Red.RawInteger,
	value2: Red.AnyType,
	op: Red.ComparisonOp
): Red.CompareResult {
	if((op == Red.ComparisonOp.FIND || op == Red.ComparisonOp.STRICT_EQUAL) && !(value2 instanceof Red.RawInteger)) {
		return 1;
	}

	const cmp = (l: number, r: number) => l < r ? -1 : (l > r ? 1 : 0);
	
	if(value2 instanceof Red.RawInteger || value2 instanceof Red.RawFloat || value2 instanceof Red.RawMoney) {
		return cmp(value1.value, value2.value);
	} else if(value2 instanceof Red.RawChar) {
		return cmp(value1.value, value2.char.charCodeAt(0));
	} else if(value2 instanceof Red.RawPercent) {
		return cmp(value1.value, value2.value/100);
	} else if(value2 instanceof Red.RawTime) {
		return cmp(value1.value, value2.toNumber());
	} else {
		// supposed to do something else but this works for now I guess
		throw new TypeError("Can't compare integer! to " + Red.TYPE_NAME(value2));
	}
}

// $$make

export function $$form(
	_ctx: Red.Context,
	value: Red.RawInteger,
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

export function $$add(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value + right.value);
	} else if(right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value + right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value + right.value / 100);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value + right.char.charCodeAt(0));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value + right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(new Red.RawInteger(left.value + right.x.value), new Red.RawInteger(left.value + right.y.value));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value + right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map((v: any) => new Red.RawInteger(left.value + v.value)));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value * 100 + v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(String.fromCharCode(left.value + v.char.charCodeAt(0))))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$add(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't add integer! with type " + Red.TYPE_NAME(right));
	}
}

export function $$subtract(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value - right.value);
	} else if(right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value - right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value - right.value / 100);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value - right.char.charCodeAt(0));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value - right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(new Red.RawInteger(left.value - right.x.value), new Red.RawInteger(left.value - right.y.value));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value - right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map((v: any) => new Red.RawInteger(left.value - v.value)));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value * 100 - v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(String.fromCharCode(left.value - v.char.charCodeAt(0))))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$subtract(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't subtract integer! with type " + Red.TYPE_NAME(right));
	}
}

export function $$multiply(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value * right.value);
	} else if(right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value * right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value * (right.value / 100));
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value * right.char.charCodeAt(0));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value * right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(new Red.RawInteger(left.value * right.x.value), new Red.RawInteger(left.value * right.y.value));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value * right.toNumber());
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map((v: any) => new Red.RawInteger(left.value * v.value)));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value * 100 * v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(String.fromCharCode(left.value * v.char.charCodeAt(0))))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$multiply(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't multiply integer! with type " + Red.TYPE_NAME(right));
	}
}

export function $$divide(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(Math.floor(left.value / right.value));
	} else if(right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value / right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value / (right.value / 100));
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(Math.floor(left.value / right.char.charCodeAt(0)));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value / right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(new Red.RawInteger(Math.floor(left.value / right.x.value)), new Red.RawInteger(Math.floor(left.value / right.y.value)));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(Math.floor(left.value / right.toNumber()));
	} else if(right instanceof Red.RawDate) {
		Red.todo();
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map((v: any) => new Red.RawInteger(Math.floor(left.value / v.value))));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value * 100 / v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(String.fromCharCode(Math.floor(left.value / v.char.charCodeAt(0)))))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$divide(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't divide integer! with type " + Red.TYPE_NAME(right));
	}
}

export function $$remainder(
	ctx:   Red.Context,
	left:  Red.RawInteger,
	right: Red.AnyType
): Red.AnyType {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value % right.value);
	} else if(right instanceof Red.RawFloat) {
		return new Red.RawFloat(left.value % right.value);
	} else if(right instanceof Red.RawPercent) {
		return new Red.RawFloat(left.value % (right.value / 100));
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value % right.char.charCodeAt(0));
	} else if(right instanceof Red.RawMoney) {
		return new Red.RawMoney(+(left.value % right.value).toFixed(2));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(new Red.RawInteger(left.value % right.x.value), new Red.RawInteger(left.value % right.y.value));
	} else if(right instanceof Red.RawTime) {
		return Red.RawTime.fromNumber(left.value % right.toNumber());
	} else if(right instanceof Red.RawTuple) {
		return new Red.RawTuple(right.values.map((v: any) => new Red.RawInteger(left.value % v.value)));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);
		
		if(Red.RawVector.isPercent(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawPercent(left.value * 100 % v.value))
			);
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(
				values
					.slice(right.index-1)
					.map(v => new Red.RawChar(String.fromCharCode(left.value % v.char.charCodeAt(0))))
			);
		} else {
			return new Red.RawVector(
				(values as any)
					.slice(right.index-1)
					.map((v: any) => $$remainder(ctx, left, v))
			);
		}
	} else {
		throw new TypeError("Can't get the remainder of integer! with type " + Red.TYPE_NAME(right));
	}
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
		return new Red.RawInteger(left.value & right.toNormalChar().charCodeAt(0));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(new Red.RawInteger(left.value & right.x.value), new Red.RawInteger(left.value & right.y.value));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);

		if(Red.RawVector.isInteger(values)) {
			return new Red.RawVector(values.map(int => new Red.RawInteger(left.value & int.value)));
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(values.map(int => new Red.RawChar(String.fromCharCode(left.value & int.toNormalChar().charCodeAt(0)))));
		} else {
			throw new Error("error!");
		}
	} else {
		return new Red.RawTuple(right.values.map(int => new Red.RawInteger(left.value & int.value)));
	}
}

export function $$complement(
	_ctx:  Red.Context,
	value: Red.RawInteger
): Red.RawInteger {
	return new Red.RawInteger(~value.value);
}

export function $$or_t(
	_ctx: Red.Context,
	left: Red.RawInteger,
	right: Red.RawInteger|Red.RawChar|Red.RawPair|Red.RawVector|Red.RawTuple
): Red.RawInteger|Red.RawPair|Red.RawVector|Red.RawTuple {
	if(right instanceof Red.RawInteger) {
		return new Red.RawInteger(left.value | right.value);
	} else if(right instanceof Red.RawChar) {
		return new Red.RawInteger(left.value | right.toNormalChar().charCodeAt(0));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(new Red.RawInteger(left.value | right.x.value), new Red.RawInteger(left.value | right.y.value));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);

		if(Red.RawVector.isInteger(values)) {
			return new Red.RawVector(values.map(int => new Red.RawInteger(left.value | int.value)));
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(values.map(int => new Red.RawChar(String.fromCharCode(left.value | int.toNormalChar().charCodeAt(0)))));
		} else {
			throw new Error("error!");
		}
	} else {
		return new Red.RawTuple(right.values.map(int => new Red.RawInteger(left.value | int.value)));
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
		return new Red.RawInteger(left.value ^ right.toNormalChar().charCodeAt(0));
	} else if(right instanceof Red.RawPair) {
		return new Red.RawPair(new Red.RawInteger(left.value ^ right.x.value), new Red.RawInteger(left.value ^ right.y.value));
	} else if(right instanceof Red.RawVector) {
		const values = right.values.slice(right.index-1);

		if(Red.RawVector.isInteger(values)) {
			return new Red.RawVector(values.map(int => new Red.RawInteger(left.value ^ int.value)));
		} else if(Red.RawVector.isChar(values)) {
			return new Red.RawVector(values.map(int => new Red.RawChar(String.fromCharCode(left.value ^ int.toNormalChar().charCodeAt(0)))));
		} else {
			throw new Error("error!");
		}
	} else {
		return new Red.RawTuple(right.values.map(int => new Red.RawInteger(left.value ^ int.value)));
	}
}