package runtime.natives;

import types.Bitset;
import types.Logic;

@:build(runtime.NativeBuilder.build())
class Complement_q {
	public static function call(bitset: Bitset) {
		return Logic.fromCond(bitset.negated);
	}
}