package runtime;

import types.base._NativeOptions;
import types.base.Options;
import types.base._Number;
import types.Value;
import types.Native;

class Natives {
	public static function callNative(native: Native, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		return switch [native.fn, args, args.map(a -> a.KIND)] {
			case [NIf(f) | NUnless(f), [cond, _], [_, KBlock(b)]]: f(cond, b);
			case [NEither(f), [cond, _, _], [_, KBlock(tb), KBlock(fb)]]: f(cond, tb, fb);
			case [NAny(f) | NAll(f) | NUntil(f) | NForever(f), _, [KBlock(b)]]: f(b);
			case [NWhile(f), _, [KBlock(cond), KBlock(body)]]: f(cond, body);
			case [NLoop(f), [Util.tryCast(_, _Number) => Some(n), _], [_, KBlock(b)]]: f(n, b);
			case [NRepeat(f), [_, Util.tryCast(_, _Number) => Some(n), _], [KWord(w), _, KBlock(b)]]: f(w, n, b);
			case [NForeach(f) | NRemoveEach(f), [word, series, _], [_, _, KBlock(b)]]: f(word, series, b);
			case [NForall(f), _, [KWord(word), KBlock(body)]]: f(word, body);
			case [NDo(f), [v], _]: f(v, Options.fromRefines(NDoOptions, refines));
			case [NGet(f), [w], _]: f(w, Options.fromRefines(NGetOptions, refines));
			case [NSet(f), [w, v], _]: f(w, v, Options.fromRefines(NSetOptions, refines));
			case [NPrint(f) | NPrin(f), [v], _]: f(v);
			case [NEqual_q(f)
				| NNotEqual_q(f)
				| NStrictEqual_q(f)
				| NLesser_q(f)
				| NGreater_q(f)
				| NLesserOrEqual_q(f)
				| NGreaterOrEqual_q(f)
				| NSame_q(f)
			, [v1, v2], _]: f(v1, v2);
			case [NTranscode(f), [v], _]: f(v, Options.fromRefines(NTranscodeOptions, refines));
			default: throw "NYI";
		}
	}
}