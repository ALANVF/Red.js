package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build("OR~"))
class Or {
	public static function call(value1: Value, value2: Value) {
		return Actions.getFor(value1).or(value1, value2);
	}
}