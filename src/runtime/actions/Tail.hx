package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Tail {
	public static function call(series: Value) {
		return Actions.getFor(series).tail(series);
	}
}