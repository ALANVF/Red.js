package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Put {
	public static final defaultOptions = Options.defaultFor(APutOptions);

	public static function call(series: Value, key: Value, value: Value, options: APutOptions) {
		return Actions.getFor(series).put(series, key, value, options);
	}
}