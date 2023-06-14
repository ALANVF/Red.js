package runtime.actions.datatypes;

import types.base.ComparisonOp;
import types.base.CompareResult;
import types.base._Integer;
import types.base._Float;
import types.Value;
import types.Integer;
import types.Float;
import types.Money;
import types.Time;
import types.Percent;
import types.String;

class PercentActions extends FloatActions<Percent> {
	override function makeThis(f: StdTypes.Float): Percent {
		return new Percent(f);
	}


	override function mold(value: Percent, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		return form(value, buffer, arg, part);
	}
}