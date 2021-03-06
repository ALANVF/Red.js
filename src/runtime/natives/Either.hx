package runtime.natives;

import types.Value;
import types.Block;

@:build(runtime.NativeBuilder.build())
class Either {
	public static function call(cond: Value, trueBlk: Block, falseBlk: Block) {
		return Do.evalValues(cond.isTruthy() ? trueBlk : falseBlk);
	}
}