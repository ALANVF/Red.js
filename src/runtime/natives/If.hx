package runtime.natives;

import types.None;
import types.Value;
import types.Block;

class If {
	public static function call(cond: Value, body: Block) {
		return cond.isTruthy() ? Do.evalValues(body) : None.NONE;
	}
}