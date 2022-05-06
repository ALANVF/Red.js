package runtime.natives;

import types.base.Symbol;
import types.Value;
import types.None;

@:build(runtime.NativeBuilder.build())
class Context_q {
	public static function call(word: Symbol): Value {
		return word.context.value._or(None.NONE);
	}
}