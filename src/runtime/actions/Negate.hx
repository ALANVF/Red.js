package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Negate {
	public static function call(value: Value) {
		return Actions.getFor(value).negate(value);
	}
}