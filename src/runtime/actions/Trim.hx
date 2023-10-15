package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Trim {
	public static final defaultOptions = Options.defaultFor(ATrimOptions);

	public static function call(series: Value, options: ATrimOptions) {
		return Actions.getFor(series).trim(series, options);
	}
}