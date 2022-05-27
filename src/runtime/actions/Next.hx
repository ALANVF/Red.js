package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Next {
	public static function call(series: Value) {
		return Actions.getFor(series).next(series);
	}
}