package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Skip {
	public static function call(series: Value, index: Value) {
		return Actions.getFor(series).skip(series, index);
	}
}