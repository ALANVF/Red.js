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
			at(i is _Integer) => (i.int).sign(),
			at(f is _Float) => (f.float).sign(),
			at(m is Money) => throw "NYI!",
			_ => throw "bad"
		));
	}
}