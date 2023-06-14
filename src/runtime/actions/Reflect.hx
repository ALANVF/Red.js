package runtime.actions;

import types.Value;
import types.Word;

@:build(runtime.ActionBuilder.build())
class Reflect {
	public static function call(value: Value, field: Word) {
		return Actions.getFor(value).reflect(value, field);
	}
}