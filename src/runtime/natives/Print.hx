package runtime.natives;

import types.Value;
import types.Unset;

import runtime.actions.Form;

@:build(runtime.NativeBuilder.build())
class Print {
	public static function call(value: Value) {
		js.html.Console.log(Form.call(Reduce.call(value, Reduce.defaultOptions), Form.defaultOptions).form());

		return Unset.UNSET;
	}
}