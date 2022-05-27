package runtime.natives;

import types.base._AnyWord;
import types.*;

@:build(runtime.NativeBuilder.build())
class Value_q {
	public static function call(value: Value) {
		value._match(
			at(sym is _AnyWord) => {
				value = sym.get(true);
			},
			_ => {}
		);

		return Logic.fromCond(value != Unset.UNSET);
	}
}