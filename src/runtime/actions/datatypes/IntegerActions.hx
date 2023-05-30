package runtime.actions.datatypes;

import types.base._ActionOptions;
import types.base._Number;
import types.base.ComparisonOp;
import types.base.CompareResult;
import types.base._Integer;
import types.base._Float;
import types.Value;
import types.Integer;
import types.Float;
import types.Char;
import types.Money;
import types.Time;
import types.Percent;
import types.Pair;
import types.Tuple;
import types.Logic;

import runtime.actions.datatypes.ValueActions.invalid;

class IntegerActions<This: _Integer = Integer> extends ValueActions<This> {
	private function makeThis(i: Int): This {
		return cast new Integer(i);
	}
	

	override function make(proto: Null<This>, spec: Value) {
		return spec._match(
			at(l is Logic) => makeThis(l.cond.asInt()),
			_ => to(proto, spec)
		);
	}

	override function to(proto: Null<This>, spec: Value) {
		return spec._match(
			at(_ is Integer) => spec,
			at(c is Char) => makeThis(c.int),
			at(t is Time) => makeThis(Std.int(t.float + 0.5)),
			at(f is _Float) => makeThis(Std.int(f.float)),
			// Money
			// Binary
			// Issue
			// Date
			// _String
			_ => invalid()
		);
	}
	
	override function compare(value1: This, value2: Value, op: ComparisonOp) {
		if((op == CFind || op == CStrictEqual) && !(value2.thisType() == value1.thisType())) {
			return IsMore;
		}
		
		final other = value2._match(
			at(i is _Integer) => i.int,
			at(_ is Money) => throw "todo!",
			at(f is _Float) => f.float,
			// ...
			_ => return IsInvalid
		);
		
		return cast (value1.int - other).sign();
	}
	
	
	/*-- Scalar actions --*/
	
	override function absolute(value: This) {
		return makeThis(Math.iabs(value.int));
	}

	override function negate(value: This) {
		return makeThis(-value.int);
	}
	
	override function add(value1: This, value2: Value) {
		final int = value1.int;
		return value2._match(
			at(i is _Integer) => makeThis(int + i.int),
			at(_ is Money) => throw "todo!",
			at(t is Time) => new Time(int + t.float),
			at(f is _Float) => new Float(int + f.float),
			at({x: x, y: y} is Pair) => new Pair(int + x, int + y),
			at(t is Tuple) => new Tuple(t.values.map(i -> i + int)),
			// Vector
			// Date
			// ...
			_ => invalid()
		);
	}

	override function subtract(value1: This, value2: Value) {
		final int = value1.int;
		return value2._match(
			at(i is _Integer) => makeThis(int - i.int),
			at(_ is Money) => throw "todo!",
			at(t is Time) => new Time(int - t.float),
			at(f is _Float) => new Float(int - f.float),
			at({x: x, y: y} is Pair) => new Pair(int - x, int - y),
			// Vector
			// Date
			// ...
			_ => invalid()
		);
	}

	override function multiply(value1: This, value2: Value) {
		final int = value1.int;
		return value2._match(
			at(i is _Integer) => makeThis(int * i.int),
			at(_ is Money) => throw "todo!",
			at(t is Time) => new Time(int * t.float),
			at(f is _Float) => new Float(int * f.float),
			at({x: x, y: y} is Pair) => new Pair(int * x, int * y),
			at(t is Tuple) => new Tuple(t.values.map(i -> i * int)),
			// Vector
			// Date
			// ...
			_ => invalid()
		);
	}

	override function divide(value1: This, value2: Value) {
		final int = value1.int;
		return value2._match(
			at(i is _Integer) => {
				if(int % i.int == 0) makeThis(Std.int(int / i.int))
				else new types.Float(int / i.int);
			},
			at(_ is Money) => throw "todo!",
			at(t is Time) => new Time(int / t.float),
			at(f is _Float) => new Float(int / f.float),
			// Vector
			// Date
			// ...
			_ => invalid()
		);
	}

	override function remainder(value1: This, value2: Value) {
		final int = value1.int;
		return value2._match(
			at(i is _Integer) => makeThis(int % i.int),
			at(_ is Money) => throw "todo!",
			at(t is Time) => new Time(int % t.float),
			at(f is _Float) => new Float(int % f.float),
			// Vector
			// Date
			// ...
			_ => invalid()
		);
	}

	override function power(number: This, exponent: _Number) {
		var base = number.int;

		return exponent._match(
			at({int: exp} is Integer, when(exp >= 0)) => {
				var res = 1;
				while(exp != 0) {
					if(cast exp & 1) {
						res *= base;
					}
					exp >>= 1;
					base *= base;
				}
				new Integer(res);
			},
			at(exp is Integer | exp is Float) => new Float(Math.pow(base, exp.asFloat())),
			_ => invalid()
		);
	}

	override function even_q(value: This) {
		return Logic.fromCond(value.int & 1 == 0);
	}

	override function odd_q(value: This) {
		return Logic.fromCond(value.int & 1 != 0);
	}

	override function round(value: This, options: ARoundOptions): Value {
		final scale = options.to?.scale;

		final num = value.int;
		if(num == 0x80000000) return value;
		var sc = 1;
		scale._match(
			at(null) => {},
			at(m is Money) => throw "not related",
			at(f is _Float) => throw "TODO",
			at(i is Integer) => {
				sc = Math.iabs(i.int);
			},
			_ => throw "bad"
		);
		if(sc == 0) return value;

		var n = Math.iabs(num);
		var r = n % sc;
		if(r == 0) return value;

		var s = sc - r;
		var m = n + s;

		inline function trunc() return num > 0 ? n - r : r - n;
		inline function floor() {
			if(m < 0) {
				throw "math overflow";
			} else {
				return num > 0 ? n - r : 0 - m;
			}
		}
		inline function ceil() {
			if(m < 0) {
				throw "math overflow";
			} else {
				return num < 0 ? r - n : m;
			}
		}
		inline function away() {
			if(m < 0) {
				throw "math overflow";
			} else {
				return num > 0 ? m : 0 - m;
			}
		}

		return new Integer(
			if(options.down) trunc()
			else if(options.floor) floor()
			else if(options.ceiling) ceil()
			else if(r < s) trunc()
			else if(r > s) away()
			else if(options.even) (Math.floor(n / sc) & 1 == 0) ? trunc() : away()
			else if(options.halfDown) trunc()
			else if(options.halfCeiling) ceil()
			else away()
		);
	}


	/*-- Bitwise actions --*/

	override function complement(value: This) {
		return makeThis(~value.int);
	}

	override function and(value1: This, value2: Value) {
		final int = value1.int;
		return value2._match(
			at(i is _Integer) => makeThis(int & i.int),
			at({x: x, y: y} is Pair) => new Pair(int & x, int & y),
			at(t is Tuple) => new Tuple(t.values.map(i -> i & int)),
			// Vector
			// Date
			// ...
			_ => invalid()
		);
	}

	override function or(value1: This, value2: Value) {
		final int = value1.int;
		return value2._match(
			at(i is _Integer) => makeThis(int | i.int),
			at({x: x, y: y} is Pair) => new Pair(int | x, int | y),
			at(t is Tuple) => new Tuple(t.values.map(i -> i | int)),
			// Vector
			// Date
			// ...
			_ => invalid()
		);
	}

	override function xor(value1: This, value2: Value) {
		final int = value1.int;
		return value2._match(
			at(i is _Integer) => makeThis(int ^ i.int),
			at({x: x, y: y} is Pair) => new Pair(int ^ x, int ^ y),
			at(t is Tuple) => new Tuple(t.values.map(i -> i ^ int)),
			// Vector
			// Date
			// ...
			_ => invalid()
		);
	}
}