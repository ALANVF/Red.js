package runtime.natives;

import types.base._Integer;
import types.base._Float;
import types.*;

@:build(runtime.NativeBuilder.build())
class Zero_q {
	public static function call(value: Value) {
		return Logic.fromCond(value._match(
			at(m is Money) => throw "NYI!",
			at({int: i} is _Integer) => i == 0,
			at({float: f} is _Float) => f == 0.0,
			at({x: x, y: y} is Pair) => x == 0 && y == 0,
			at({values: values} is Tuple) => values.every(v -> v == 0),
			_ => throw "error!"
		));
	}
}