package runtime.natives;

import types.base._AnyWord;
import types.Value;
import types.None;

@:build(runtime.NativeBuilder.build())
class Context_q {
	public static function call(word: _AnyWord): Value {
		return word.context.value._or(None.NONE);
	}
}