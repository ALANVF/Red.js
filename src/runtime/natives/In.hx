package runtime.natives;

import types.*;
import types.base.Symbol;

@:build(runtime.NativeBuilder.build())
class In {
	public static function call(object: Object, word: Symbol): Value {
		return switch object.ctx.offsetOfSymbol(word) {
			case -1: None.NONE;
			case offset: object.ctx.getOffsetSymbol(offset);
		}
	}
}