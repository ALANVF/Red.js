package runtime.natives;

import types.Integer;
import types.Word;
import types.Error;
import types.Block;
import types.None;
import types.base._Float;
import types.base._Integer;
import types.base._Number;

@:build(runtime.NativeBuilder.build())
class Repeat {
	public static function call(word: Word, times: _Number, body: Block) {
		final n = if(times is _Integer) {
			cast(times, _Integer).int;
		} else {
			Std.int(cast(times, _Float).float);
		};

		for(i in 0...n) {
			try {
				word.setValue(new Integer(i));
				Do.evalValues(body).isTruthy();
			} catch(e: Error) {
				if(e.isContinue()) {
					continue;
				} else if(e.isBreak()) {
					return e.get("arg1");
				} else {
					throw e;
				}
			}
		}

		return None.NONE;
	}
}