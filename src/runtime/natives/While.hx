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
			} catch(e: Error) {
				if(e.type == "throw" && (e.id == "break" || e.id == "continue")) {
					throw Error.create({type: "throw", id: "while-cond"});
				} else {
					throw e;
				}
			}
		}) {
			try {
				Do.evalValues(body).isTruthy();
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