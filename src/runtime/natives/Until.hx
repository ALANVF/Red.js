package runtime.natives;

import types.Error;
import types.Block;

class Until {
	public static function call(body: Block) {
		var res;
		
		do {
			try {
				res = Do.evalValues(body);
			} catch(e: Error) {
				if(e.type == "throw" && e.id == "continue") {
					continue;
				} else if(e.type == "throw" && e.id == "break") {
					return e.get("arg1");
				} else {
					throw e;
				}
			}
		} while(!res.isTruthy());

		return res;
	}
}