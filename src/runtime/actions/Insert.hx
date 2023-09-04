package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Insert {
	public static final defaultOptions = Options.defaultFor(AInsertOptions);

	public static function call(series: Value, value: Value, options: AInsertOptions) {
		return Actions.getFor(series).insert(series, value, options);
	}
}