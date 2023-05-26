package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build("XOR~"))
class Xor {
	public static function call(value1: Value, value2: Value) {
		return Actions.getFor(value1).xor(value1, value2);
	}
}