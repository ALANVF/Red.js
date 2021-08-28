package runtime.natives;

import types.Value;
import types.None;
import types.Block;

@:build(runtime.NativeBuilder.build())
class All {
	public static function call(conds: Block): Value {
		var result: Value = None.NONE;
		var tokens: Series<Value> = conds;
		
		while(tokens.isNotTail()) {
			switch Do.doNextValue(tokens) {
				case {_1: _.isTruthy() => false}: return None.NONE;
				case {_1: v, _2: rest}:
					result = v;
					tokens = rest;
			}
		}
		
		return result;
	}
}

