package runtime.natives;

import types.Value;
import types.Unset;
import types.Block;

import runtime.actions.Form;

@:build(runtime.NativeBuilder.build())
class Print {
	public static function call(value: Value) {
		RedJS.printHandler(
			Form.call(
				if(value is Block) Reduce.call(value, Reduce.defaultOptions) else value,
				Form.defaultOptions
			).toJs()
		);

		return Unset.UNSET;
	}
}