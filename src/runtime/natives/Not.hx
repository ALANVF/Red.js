package runtime.natives;

import types.Value;
import types.Logic;

@:build(runtime.NativeBuilder.build())
class Not {
	public static function call(value: Value) {
		return Logic.fromCond(!value.isTruthy());
	}
}