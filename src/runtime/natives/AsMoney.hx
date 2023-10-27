package runtime.natives;

import types.base._Number;
import types.Integer;
import types.Float;
import types.Word;

import runtime.actions.datatypes.MoneyActions;

@:build(runtime.NativeBuilder.build())
class AsMoney {
	public static function call(currency: Word, amount: _Number) {
		return amount._match(
			at(i is Integer) => MoneyActions.fromInteger(i, currency),
			at(f is Float) => MoneyActions.fromFloat(f, currency),
			_ => throw "bad"
		);
	}
}