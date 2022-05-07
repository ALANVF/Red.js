package runtime.natives;

import types.base._Integer;
import types.base._Float;
import types.Value;
import types.Integer;
import types.Money;

@:build(runtime.NativeBuilder.build())
class Sign_q {
	public static function call(value: Value): Integer {
		return new Integer(value._match(
			at(i is _Integer) => js.lib.Math.sign(i.int),
			at(f is _Float) => js.lib.Math.sign(f.float),
			at(m is Money) => throw "NYI!",
			_ => throw "bad"
		));
	}
}