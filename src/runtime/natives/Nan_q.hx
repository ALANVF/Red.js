package runtime.natives;

import types.base._Number;
import types.Logic;

@:build(runtime.NativeBuilder.build())
class Nan_q {
	public static function call(value: _Number) {
		return Logic.fromCond(Math.isNaN(value.asFloat()));
	}
}