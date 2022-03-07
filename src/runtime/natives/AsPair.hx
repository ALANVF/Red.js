package runtime.natives;

import types.base._Number;
import types.Pair;

@:build(runtime.NativeBuilder.build())
class AsPair {
	public static function call(x: _Number, y: _Number) {
		return new Pair(x.asInt(), y.asInt());
	}
}