package runtime.actions.datatypes;

import types.base.ComparisonOp;
import types.base.CompareResult;
import types.base._Integer;
import types.base._Float;
import types.Value;
import types.Integer;
import types.Char;
import types.Money;
import types.Time;
import types.Percent;
import types.Pair;
import types.Tuple;

import runtime.actions.datatypes.ValueActions.invalid;

class IntegerActions<This: _Integer> extends ValueActions<This> {
	private function makeThis(i: Int): This {
		return untyped new Integer(i);
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
		
		return cast js.lib.Math.sign(value1.int - other);
	}
	
	
	/*-- Scalar actions --*/
	
	override function absolute(value: This) {
		return makeThis(Math.iabs(value.int));
	}
	
	override function add(value1: This, value2: Value) {
		final int = value1.int;
		return value2._match(
			at(i is _Integer) => makeThis(int + i.int),
			at(_ is Money) => throw "todo!",
			at(f is _Float) => f.make(int + f.float),
			at({x: x, y: y} is Pair) => new Pair(int + x, int + y),
			at(t is Tuple) => new Tuple(t.values.map(i -> i + int)),
			// Vector
			// Date
			// ...
			_ => untyped invalid()
		);
	}
}