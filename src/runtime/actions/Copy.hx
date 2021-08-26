package runtime.actions;

import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Copy {
	public static function call(value: Value, options: ACopyOptions) {
		return Actions.getFor(value).copy(value, options);
	}
}