package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Remove {
	public static final defaultOptions = Options.defaultFor(ARemoveOptions);

	public static function call(series: Value, options: ARemoveOptions) {
		return Actions.getFor(series).remove(series, options);
	}
}