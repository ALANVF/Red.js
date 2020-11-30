package runtime.natives;

import types.None;
import types.Value;
import types.Block;

class Unless {
	public static function call(cond: Value, body: Block) {
		return cond.isTruthy() ? None.NONE : Do.evalValues(body);
	}
}