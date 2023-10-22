package runtime.actions.datatypes;

import types.base.MathOp;
import types.base._ActionOptions;
import types.base._Number;
import types.base.ComparisonOp;
import types.base.CompareResult;
import types.base._Integer;
import types.base._Float;
import types.Value;
import types.Integer;
import types.Char;
import types.Money;
import types.Float;
import types.Time;
import types.Percent;
import types.Pair;
import types.Tuple;
import types.String;

import runtime.actions.datatypes.ValueActions.invalid;

class CharActions extends IntegerActions<Char> {
	override function makeThis(i: Int): Char {
		return Char.fromCode(i);
	}


	override function make(proto: Null<Char>, spec: Value) {
		return to(proto, spec);
	}

	override function to(proto: Null<Char>, spec: Value) {
		return spec._match(
			at(c is Char) => c,
			at(i is Integer) => {
				if(i.int > Char.MAX_CODEPOINT || i.int < 0) throw "out of range";
				inline makeThis(i.int);
			},
			at(f is Float | f is Percent) => {
				final i = Std.int(f.float);
				if(i > Char.MAX_CODEPOINT || i < 0) throw "out of range";
				inline makeThis(i);
			},
			// Binary
			at(s is types.base._String) => {
				if(s.length == 0) throw "bad";
				inline makeThis(s.rawFastPick(0));
			},
			_ => invalid()
		);
	}

	override function form(value: Char, buffer: String, arg: Null<Int>, part: Int) {
		buffer.values.push(value.int);
		return part - 1;
	}

	override function mold(value: Char, buffer: String, _, isAll: Bool, _, arg: Null<Int>, part: Int, _) {
		buffer.appendLiteral('#"');
		buffer.appendEscapedChar(value.int, true, isAll);
		buffer.appendChar('"'.code);
		return part - 4;
	}
	

	override function compare(value1: Char, value2: Value, op: ComparisonOp) {
		if((op == CFind || op == CStrictEqual) && !(value2.thisType() == value1.thisType())) {
			return IsMore;
		}

		final other = value2._match(
			at(i is _Integer) => i.int,
			_ => return IsInvalid
		);

		return cast (value1.int - other).sign();
	}

	override function doMath(left: Value, right: Value, op: MathOp): Value {
		left._match(
			at(l is Char) => {
				final rv = right._match(
					at(r is _Integer) => r.int,
					at(r is Float) => Std.int(r.float),
					// Vector
					_ => invalid()
				);

				final res = Char.fromCode(cast IntegerActions.doMathOp(l.int, rv, op, true));
				if(res.int > Char.MAX_CODEPOINT || res.int <= 0) throw "math overflow";
				return res;
			},
			_ => invalid()
		);
	}

	
	/*-- Scalar actions --*/

	override function negate(value: Char): Char invalid();

	override function power(number: Char, exponent: _Number): _Number invalid();

	override function round(value: Char, options: ARoundOptions): _Integer invalid();

	/*-- Bitwise actions --*/

	override function complement(value: Char): Char invalid();
}