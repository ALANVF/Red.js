package runtime.natives;

import types.Value;
import types.Unset;

@:build(runtime.NativeBuilder.build())
class Print {
	public static function call(value: Value) {
		js.html.Console.log(value);

		return Unset.UNSET;
	}
}