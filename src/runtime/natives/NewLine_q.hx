package runtime.natives;

import types.base._Block;
import types.Logic;

@:build(runtime.NativeBuilder.build())
class NewLine_q {
	public static function call(list: _Block): Logic {
		return Logic.fromCond(list.hasNewline(list.index));
	}
}