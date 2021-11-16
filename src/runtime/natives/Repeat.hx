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
		final n = times._match(
			at({int: i} is _Integer) => i,
			at({float: f} is _Float) => Std.int(f)
		);

		for(i in 0...n) {
			try {
				word.setValue(new Integer(i));
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