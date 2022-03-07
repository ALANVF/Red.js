package runtime.natives;

import types.base.Symbol;
import types.*;

@:build(runtime.NativeBuilder.build())
class Value_q {
	public static function call(value: Value) {
		value._match(
			at(sym is Symbol) => {
				value = sym.getValue(true);
			},
			_ => {}
		);

		return Logic.fromCond(value != Unset.UNSET);
	}
}