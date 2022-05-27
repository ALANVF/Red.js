package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class At {
	public static function call(series: Value, index: Value) {
		return Actions.getFor(series).at(series, index);
	}
}