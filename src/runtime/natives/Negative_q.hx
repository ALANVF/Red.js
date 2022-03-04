package runtime.natives;

import types.Value;
import types.Logic;
import types.base._Integer;
import types.base._Float;
import types.Money;

@:build(runtime.NativeBuilder.build())
class Negative_q {
	public static function call(value: Value) {
		return Logic.fromCond(value._match(
			at({int: i} is _Integer) => i < 0,
			at({float: f} is _Float) => f < 0.0,
			at(m is Money) => throw "NYI!",
			_ => throw "bad"
		));
	}
}