package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Reverse {
	public static final defaultOptions = Options.defaultFor(AReverseOptions);
	
	public static function call(series: Value, options: AReverseOptions) {
		return Actions.getFor(series).reverse(series, options);
	}
}