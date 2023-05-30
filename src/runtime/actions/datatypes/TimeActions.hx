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

class TimeActions extends FloatActions<Time> {
	override function makeThis(f: StdTypes.Float): Time {
		return new Time(f);
	}
}