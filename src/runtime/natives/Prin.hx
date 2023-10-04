package runtime.natives;

import types.Value;
import types.Unset;

import runtime.actions.Form;

@:build(runtime.NativeBuilder.build())
class Prin {
	public static function call(value: Value) {
		if(Util.IS_NODE) {
			#if js
			js.Syntax.code("process.stdout.write({0})", Form.call(value, Form.defaultOptions).form());
			#end
		} else {
			throw "Can't use `prin` on web!";
		}

		return Unset.UNSET;
	}
}