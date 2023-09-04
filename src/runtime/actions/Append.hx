package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Append {
	public static final defaultOptions = Options.defaultFor(AAppendOptions);

	public static function call(series: Value, value: Value, options: AAppendOptions) {
		return Actions.getFor(series).append(series, value, options);
	}
}