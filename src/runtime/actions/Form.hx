package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;
import types.String;

@:build(runtime.ActionBuilder.build())
class Form {
	public static final defaultOptions = Options.defaultFor(AFormOptions);

	public static function call(value: Value, options: AFormOptions) {
		final arg = options.part?.limit.int;
		var expected = 0;
		final limit = arg._andOr(int => {
			if(arg <= 0) return new String([]);
			expected = int;
			int;
		}, cast Math.POSITIVE_INFINITY);

		final buffer = new String([]);
		Actions.getFor(value).form(value, buffer, arg, limit);

		if(expected > 0) buffer.values.resize(expected);
		return buffer;
	}
}