package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Add {
	public static function call(value1: Value, value2: Value) {
		return Actions.getFor(value1).add(value1, value2);
	}
}