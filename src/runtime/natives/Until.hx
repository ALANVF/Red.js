package runtime.natives;

import types.Error;
import types.Block;

@:build(runtime.NativeBuilder.build())
class Until {
	public static function call(body: Block) {
		var res;
		
		do {
			try {
				res = Do.evalValues(body);
			} catch(e: Error) {
				if(e.isContinue()) {
					continue;
				} else if(e.isBreak()) {
					return e.get("arg1");
				} else {
					throw e;
				}
			}
		} while(!res.isTruthy());

		return res;
	}
}