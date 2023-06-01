package runtime.actions.datatypes;

import types.base.MathOp;
import types.base._ActionOptions;
import types.base.ComparisonOp;
import types.base.CompareResult;
import types.base._Number;
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

	static function doMathOp(left: Int, right: Int, op: MathOp, forceIntDiv: Bool): StdTypes.Float {
		return op._match(
			at(OAdd) => left + right,
			at(OSub) => left - right,
			at(OMul) => left * right,
			at(OAnd) => left & right,
			at(OOr) => left | right,
			at(OXor) => left ^ right,
			at(ORem) => left % right,
			at(ODiv) => {
				if(forceIntDiv || left % right == 0) Std.int(left / right);
				else left / right;
			},
			_ => throw "bad"
		);
	}

	override function doMath(left: Value, right: Value, op: MathOp) {
		return left._match(
			at(l is _Integer) => right._match(
				at(r is _Integer) => {
					final res = doMathOp(l.int, r.int, op, false);
					if(res % 1.0 != 0.0) new Float(res);
					else makeThis(cast res);
				},
				// Money,
				at(r is _Float) => Actions.get(DFloat).doMath(l, r, op),
				at(r is Pair) => {
					final pairActions = Actions.get(DPair);
					if(op == ODiv) throw "not related";
					if(op == OSub) {
						r = cast pairActions.negate(r);
						op = OAdd;
					}
					pairActions.doMath(r, l, op);
				},
				at(r is Tuple) => {
					if(op == OSub || op == ODiv) throw "not related";
					Actions.get(DTuple).doMath(r, l, op);
				},
				// Vector
				// Date
				_ => invalid()
			),
			_ => invalid()
		);
	}
	
	
	/*-- Scalar actions --*/
	
	override function absolute(value: This) {
		return makeThis(Math.iabs(value.int));
	}

	override function negate(value: This) {
		return makeThis(-value.int);
	}
	
	override function add(value1: This, value2: Value) {
		return doMath(value1, value2, OAdd);
	}

	override function subtract(value1: This, value2: Value) {
		return doMath(value1, value2, OSub);
	}

	override function multiply(value1: This, value2: Value) {
		return doMath(value1, value2, OMul);
	}

	override function divide(value1: This, value2: Value) {
		return doMath(value1, value2, ODiv);
	}

	override function remainder(value1: This, value2: Value) {
		return doMath(value1, value2, ORem);
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

	override function round(value: This, options: ARoundOptions): _Integer {
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
		return doMath(value1, value2, OAnd);
	}

	override function or(value1: This, value2: Value) {
		return doMath(value1, value2, OOr);
	}

	override function xor(value1: This, value2: Value) {
		return doMath(value1, value2, OXor);
	}
}