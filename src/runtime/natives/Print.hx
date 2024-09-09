package runtime.natives;

import types.Value;
import types.Unset;

import runtime.actions.Form;

@:build(runtime.NativeBuilder.build())
class Print {
	public static function call(value: Value) {
		RedJS.printHandler(Form.call(Reduce.call(value, Reduce.defaultOptions), Form.defaultOptions).toJs());

		return Unset.UNSET;
	}
}