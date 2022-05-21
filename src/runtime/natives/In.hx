package runtime.natives;

import types.*;
import types.base._Word;

@:build(runtime.NativeBuilder.build())
class In {
	public static function call(object: Object, word: _Word): Value {
		return switch object.ctx.offsetOfSymbol(word.symbol) {
			case -1: None.NONE;
			case offset: word.copyFrom(object.ctx.symbols[offset]);
		}
	}
}