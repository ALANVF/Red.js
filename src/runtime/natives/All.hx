package runtime.natives;

import types.Value;
import types.None;
import types.Block;

@:build(runtime.NativeBuilder.build())
class All {
	public static function call(conds: Block): Value {
		var result: Value = None.NONE;
		
		while(!conds.isTail()) {
			switch Do.doNextValue(conds) {
				case {value: _.isTruthy() => false}: return None.NONE;
				case {value: v, offset: o}:
					result = v;
					conds = conds.skip(o);
			}
		}
		
		return result;
	}
}

