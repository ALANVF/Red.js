package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Pick {
	public static function call(series: Value, index: Value) {
		return Actions.getFor(series).pick(series, index);
	}
}