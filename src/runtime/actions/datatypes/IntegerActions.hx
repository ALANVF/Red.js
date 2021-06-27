package runtime.actions.datatypes;

import types.base.ComparisonOp;
import types.base.CompareResult;
import types.Integer;
import types.Char;
import types.Money;
import types.Time;
import types.Percent;
import types.Value;

class IntegerActions extends ValueActions {
	override public function compare(value1: Value, value2: Value, op: ComparisonOp) {
		if((op == CFind || op == CStrictEqual) && !(value2 is Integer)) {
			return IsMore;
		}
		
		final int = cast(value1, Integer).int;
		final other = value2._match(
			at(i is Integer) => i.int,
			at(c is Char) => c.code,
			at(_ is Money) => throw "todo!",
			at(f is types.Float | f is Percent) => f.float,
			at(t is Time) => t.toFloat(),
			_ => return IsInvalid
		);
		
		return cast js.lib.Math.sign(int - other);
	}
}