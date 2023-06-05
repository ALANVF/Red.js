package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Round {
	public static final defaultOptions = Options.defaultFor(ARoundOptions);

	public static function call(value: Value, options: ARoundOptions): Value {
		return Actions.getFor(value).round(value, options);
	}
}