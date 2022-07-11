package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Map;

class MapActions extends ValueActions<Map> {
	override function compare(value1: Map, value2: Value, op: ComparisonOp): CompareResult {
		// oh hell nah https://github.com/red/red/blob/master/runtime/datatypes/map.reds#L366

		throw "NYI";
	}
}