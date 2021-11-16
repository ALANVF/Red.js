package runtime.natives;

import types.Value;
import types.Unset;
import types.Error;

@:build(runtime.NativeBuilder.build())
class Return {
	public static function call(value: Value): Unset {
		throw new RedError(Error.create({
			code: 1,
			type: "throw",
			id: "return",
			arg1: value
		}));
	}
}