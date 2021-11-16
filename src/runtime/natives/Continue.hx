package runtime.natives;

import types.Unset;
import types.Error;

@:build(runtime.NativeBuilder.build())
class Continue {
	public static function call(): Unset {
		throw new RedError(Error.create({
			code: 3,
			type: "throw",
			id: "continue"
		}));
	}
}