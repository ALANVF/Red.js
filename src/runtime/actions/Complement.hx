package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Complement {
	public static function call(value: Value) {
		return Actions.getFor(value).complement(value);
	}
}