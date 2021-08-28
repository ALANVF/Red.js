package runtime.natives;

import types.Value;
import types.None;
import types.Block;

@:build(runtime.NativeBuilder.build())
class Any {
	public static function call(conds: Block) {
		var tokens: Series<Value> = conds;

		while(tokens.isNotTail()) {
			switch Do.doNextValue(tokens) {
				case {_1: v} if(v.isTruthy()): return v;
				case {_2: rest}: tokens = rest;
			}
		}
		
		return None.NONE;
	}
}