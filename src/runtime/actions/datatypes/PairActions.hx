package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Pair;
import types.Integer;
import types.Logic;
import types.None;

class PairActions extends ValueActions<Pair> {
	override function compare(value1: Pair, value2: Value, op: ComparisonOp): CompareResult {
		final pair2 = value2._match(
			at(p is Pair) => p,
			_ => return IsInvalid
		);

		var diff = value1.x - pair2.x;
		if(diff == 0) diff = value1.y - pair2.y;
		return cast diff.sign();
	}
}