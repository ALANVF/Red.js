package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;
import types.String;

@:build(runtime.ActionBuilder.build())
class Mold {
	public static final defaultOptions = Options.defaultFor(AMoldOptions);

	public static function call(value: Value, options: AMoldOptions) {
		final arg = options.part?.limit.int;
		var expected = 0;
		final limit = arg._andOr(int => {
			if(arg <= 0) return new String([]);
			expected = int;
			int;
		}, cast Math.POSITIVE_INFINITY);

		final buffer = new String([]);
		Actions.getFor(value).mold(
			value, buffer,
			options.only, options.all, options.flat,
			arg, limit,
			0
		);

		if(expected > 0) buffer.values.resize(expected);
		return buffer;
	}

	public static inline function _call(
		value: Value, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		value ??= types.Tag.fromString("null");
		return Actions.getFor(value).mold(value, buffer, isOnly, isAll, isFlat, arg, part, indent);
	}
}