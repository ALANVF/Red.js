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

class CharActions extends IntegerActions<Char> {
	override function makeThis(i: Int): Char {
		return Char.fromCode(i);
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

	// TODO: redo add
}