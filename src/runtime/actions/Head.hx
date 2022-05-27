package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Head {
	public static function call(series: Value) {
		return Actions.getFor(series).head(series);
	}
}