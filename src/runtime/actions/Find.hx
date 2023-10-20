package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Find {
	public static final defaultOptions = Options.defaultFor(AFindOptions);

	public static function call(series: Value, value: Value, options: AFindOptions) {
		return Actions.getFor(series).find(series, value, options);
	}
}