package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build("AND~"))
class And {
	public static function call(value1: Value, value2: Value) {
		return Actions.getFor(value1).and(value1, value2);
	}
}