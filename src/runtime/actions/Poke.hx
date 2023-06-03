package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Poke {
	public static function call(series: Value, index: Value, value: Value) {
		return Actions.getFor(series).poke(series, index, value);
	}
}