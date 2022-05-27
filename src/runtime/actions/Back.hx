package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Back {
	public static function call(series: Value) {
		return Actions.getFor(series).back(series);
	}
}