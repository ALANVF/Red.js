package runtime.actions;

import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Reverse {
	public static function call(series: Value, options: AReverseOptions) {
		return Actions.getFor(series).reverse(series, options);
	}
}