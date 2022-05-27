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

class IntegerActions extends _IntegerActions<Integer> {
	function makeThis(i: Int): Integer {
		return new Integer(i);
	}
}