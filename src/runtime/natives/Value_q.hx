package runtime.natives;

import types.base._Word;
import types.*;

@:build(runtime.NativeBuilder.build())
class Value_q {
	public static function call(value: Value) {
		value._match(
			at(sym is _Word) => {
				value = sym.get(true);
			},
			_ => {}
		);

		return Logic.fromCond(value != Unset.UNSET);
	}
}