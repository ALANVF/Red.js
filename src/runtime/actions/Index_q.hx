package runtime.actions;

import types.Value;
import types.Integer;

@:build(runtime.ActionBuilder.build())
class Index_q {
	public static function call(series: Value): Integer {
		return Actions.getFor(series).index_q(series);
	}
}