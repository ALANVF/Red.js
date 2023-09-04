package runtime.actions;

import types.Value;

@:build(runtime.ActionBuilder.build())
class Clear {
	public static function call(value: Value) {
		return Actions.getFor(value).clear(value);
	}
}