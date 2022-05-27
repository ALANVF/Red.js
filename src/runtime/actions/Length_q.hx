package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Length_q {
	public static function call(series: Value) {
		return Actions.getFor(series).length_q(series);
	}
}