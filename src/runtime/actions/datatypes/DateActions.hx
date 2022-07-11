package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Date;

class DateActions extends ValueActions<Date> {
	override function compare(value1: Date, value2: Value, op: ComparisonOp): CompareResult {
		throw "NYI";
	}
}