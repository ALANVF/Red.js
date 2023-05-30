package runtime.actions;

import types.Value;
import types.Logic;

@:build(runtime.ActionBuilder.build())
class Even_q {
	public static function call(value: Value): Logic {
		return Actions.getFor(value).even_q(value);
	}
}