package runtime.natives;

import types.Error;
import types.Block;
import types.None;
import types.base._Float;
import types.base._Integer;
import types.base._Number;

@:build(runtime.NativeBuilder.build())
class Loop {
	public static function call(times: _Number, body: Block) {
		final n = if(times is _Integer) {
			cast(times, _Integer).int;
		} else {
			Std.int(cast(times, _Float).float);
		};

		for(_ in 0...n) {
			try {
				Do.evalValues(body);
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