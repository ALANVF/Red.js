package runtime.natives;

import types.None;
import types.Block;

class Any {
	public static function call(conds: Block) {
		while(!conds.isTail()) {
			switch Do.doNextValue(conds) {
				case {value: v} if(v.isTruthy()): return v;
				case {offset: o}: conds = conds.skip(o);
			}
		}
		
		return None.NONE;
	}
}