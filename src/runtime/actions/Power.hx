package runtime.actions;

import types.Value;
import types.base._Number;

@:build(runtime.ActionBuilder.build())
class Power {
	public static function call(number: Value, exponent: _Number): _Number {
		return Actions.getFor(number).power(number, exponent);
	}
}