package runtime.natives;

import types.None;
import types.Error;
import types.Block;

@:build(runtime.NativeBuilder.build())
class While {
	public static function call(cond: Block, body: Block) {
		while({
			try {
				Do.evalValues(cond).isTruthy();
			} catch(e: RedError) {
				if(e.isBreak() || e.isContinue()) {
					throw Error.create({type: "throw", id: "while-cond"});
				} else {
					throw e;
				}
			}
		}) {
			try {
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