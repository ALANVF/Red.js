package runtime.actions;

import types.Value;
import types.Logic;

@:build(runtime.ActionBuilder.build())
class Tail_q {
	public static function call(series: Value): Logic {
		return Actions.getFor(series).tail_q(series);
	}
}