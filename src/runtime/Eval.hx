package runtime;

import types.Native;
import types.Action;
import types.Function;
import types.Op;
import types.base.IFunction;
import types.Value;

class Eval {
	public static function evalCode(input: String) {
		return runtime.natives.Do.evalValues(Tokenizer.parse(input));
	}

	public static function callFunction(fn: IFunction, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		return fn._match(
			at(n is Native) => Natives.callNative(n, args, refines),
			at(a is Action) => Actions.callAction(a, args, refines),
			at(_ is Function | _ is Op) => throw "NYI",
			_ => throw "error!"
		);
	}
}