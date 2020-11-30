package runtime;

import types.Value;
import types.Native;

class Natives {
	public static function callNative(native: Native, args: Array<Value>, refines: Map<String, Array<Value>>) {
		return switch [native.fn, args, args.map(a -> a.KIND)] {
			case [NIf(f) | NUnless(f) | NWhile(f), [cond, _], [_, KBlock(b)]]: f(cond, b);
			case [NEither(f), [cond, _, _], [_, KBlock(tb), KBlock(fb)]]: f(cond, tb, fb);
			default:
				throw "NYI";
		}
	}
}