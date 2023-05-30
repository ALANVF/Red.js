package runtime.actions;

import types.Value;
import types.Logic;

@:build(runtime.ActionBuilder.build())
class Odd_q {
	public static function call(value: Value): Logic {
		return Actions.getFor(value).odd_q(value);
	}
}