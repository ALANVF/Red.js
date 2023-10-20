package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Select {
	public static final defaultOptions = Options.defaultFor(ASelectOptions);

	public static function call(series: Value, value: Value, options: ASelectOptions) {
		return Actions.getFor(series).select(series, value, options);
	}
}