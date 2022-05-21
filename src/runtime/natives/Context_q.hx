package runtime.natives;

import types.base._Word;
import types.Value;
import types.None;

@:build(runtime.NativeBuilder.build())
class Context_q {
	public static function call(word: _Word): Value {
		return word.context.value._or(None.NONE);
	}
}