package runtime;

import types.Native;
import types.base.IFunction;
import types.Value;

class Eval {
	public static function evalCode(input: String) {
		return runtime.natives.Do.evalValues(Tokenizer.parse(input));
	}

	public static function callFunction(fn: IFunction, args: Array<Value>, refines: Map<String, Array<Value>>) {
		return switch fn.KIND {
			case KNative(n): Natives.callNative(n, args, refines);
			case KAction(a): Actions.callAction(a, args, refines);
			case KFunction(_) | KOp(_): throw "NYI";
			default: throw "error!";
		}
	}
}