package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.Value;
import types.Unset;
import types.Error;

@:build(runtime.NativeBuilder.build())
class Throw {
	public static final defaultOptions = Options.defaultFor(NThrowOptions);

	public static function call(value: Value, options: NThrowOptions): Unset {
		throw new RedError(Error.create({
			code: 2,
			type: "throw",
			id: "throw",
			arg1: value
		}), options.name?.word);
	}
}