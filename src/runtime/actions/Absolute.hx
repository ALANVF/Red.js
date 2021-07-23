package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Absolute {
	public static function call(value: Value) {
		return Actions.getFor(value).absolute(value);
	}
}