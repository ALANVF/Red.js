package runtime.natives;

import types.Value;
import types.Unset;

import runtime.actions.Form;

@:build(runtime.NativeBuilder.build())
class Prin {
	public static function call(value: Value) {
		RedJS.prinHandler(Form.call(value, Form.defaultOptions).toJs());

		return Unset.UNSET;
	}
}