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
		final n = times._match(
			at({int: i} is _Integer) => i,
			at({float: f} is _Float) => Std.int(f)
		);

		for(_ in 0...n) {
			try {
				Do.evalValues(body);
			} catch(e: RedError) {
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