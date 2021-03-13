package runtime.natives;

import types.None;
import types.Error;
import types.Block;

@:build(runtime.NativeBuilder.build())
class Forever {
	public static function call(body: Block) {
		while(true) {
			try {
				Do.evalValues(body);
			} catch(e: Error) {
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