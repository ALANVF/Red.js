package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Take {
	public static final defaultOptions = Options.defaultFor(ATakeOptions);

	public static function call(series: Value, options: ATakeOptions) {
		return Actions.getFor(series).take(series, options);
	}
}