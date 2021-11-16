package runtime.natives;

import types.Unset;
import types.None;
import types.Error;

@:build(runtime.NativeBuilder.build())
class Exit {
	public static function call(): Unset {
		throw new RedError(Error.create({
			code: 1,
			type: "throw",
			id: "return"
		}));
	}
}