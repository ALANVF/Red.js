package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.Unset;
import types.Error;

@:build(runtime.NativeBuilder.build())
class Break {
	public static final defaultOptions = Options.defaultFor(NBreakOptions);

	public static function call(options: NBreakOptions): Unset {
		throw new RedError(Error.create({
			code: 0,
			type: "throw",
			id: "break",
			arg1: options._return._match(
				at({value: value}) => value,
				_ => null
			)
		}));
	}
}