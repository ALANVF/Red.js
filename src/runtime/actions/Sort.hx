package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Sort {
	public static final defaultOptions = Options.defaultFor(ASortOptions);

	public static function call(series: Value, options: ASortOptions) {
		return Actions.getFor(series).sort(series, options);
	}
}