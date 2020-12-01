package runtime;

import types.base._NativeOptions;
import types.base.Options;
import types.Value;
import types.Native;

class Natives {
	public static function callNative(native: Native, args: Array<Value>, refines: Map<String, Array<Value>>) {
		return switch [native.fn, args, args.map(a -> a.KIND)] {
			case [NIf(f) | NUnless(f) | NWhile(f), [cond, _], [_, KBlock(b)]]: f(cond, b);
			case [NEither(f), [cond, _, _], [_, KBlock(tb), KBlock(fb)]]: f(cond, tb, fb);
			case [NDo(f), [v], _]: f(v, Options.fromRefines(NDoOptions, refines));
			case [NTranscode(f), [v], _]: f(v, Options.fromRefines(NTranscodeOptions, refines));
			default:
				throw "NYI";
		}
	}
}