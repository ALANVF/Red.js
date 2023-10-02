package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Swap {
	public static function call(series1: Value, series2: Value): Value {
		return Actions.getFor(series1).swap(series1, series2);
	}
}