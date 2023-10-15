package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Change {
	public static final defaultOptions = Options.defaultFor(AChangeOptions);

	public static function call(series: Value, value: Value, options: AChangeOptions) {
		return Actions.getFor(series).change(series, value, options);
	}
}