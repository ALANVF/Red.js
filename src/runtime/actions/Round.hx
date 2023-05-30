package runtime.actions;

import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Round {
	public static function call(value: Value, options: ARoundOptions): Value {
		return Actions.getFor(value).round(value, options);
	}
}