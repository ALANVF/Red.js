package runtime;

import types.Word;
import types.Block;
import types.base._NativeOptions;
import types.base.Options;
import types.base._Number;
import types.Value;
import types.Native;

class Natives {
	public static function callNative(native: Native, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		return Util._match([native.fn, args],
			at([NIf(f) | NUnless(f), [cond, b is Block]]) => f(cond, b),
			at([NEither(f), [cond, tb is Block, fb is Block]]) => f(cond, tb, fb),
			at([NAny(f) | NAll(f) | NUntil(f) | NForever(f), [b is Block]]) => f(b),
			at([NWhile(f), [cond is Block, body is Block]]) => f(cond, body),
			at([NLoop(f), [n is _Number, b is Block]]) => f(n, b),
			at([NRepeat(f), [w is Word, n is _Number, b is Block]]) => f(w, n, b),
			at([NForeach(f) | NRemoveEach(f), [word, series, b is Block]]) => f(word, series, b),
			at([NForall(f), [word is Word, body is Block]]) => f(word, body),
			at([NDo(f), [v]]) => f(v, Options.fromRefines(NDoOptions, refines)),
			at([NReduce(f), [v]]) => f(v, Options.fromRefines(NReduceOptions, refines)),
			at([NGet(f), [w]]) => f(w, Options.fromRefines(NGetOptions, refines)),
			at([NSet(f), [w, v]]) => f(w, v, Options.fromRefines(NSetOptions, refines)),
			at([NPrint(f) | NPrin(f), [v]]) => f(v),
			at([NEqual_q(f)
				| NNotEqual_q(f)
				| NStrictEqual_q(f)
				| NLesser_q(f)
				| NGreater_q(f)
				| NLesserOrEqual_q(f)
				| NGreaterOrEqual_q(f)
				| NSame_q(f)
			, [v1, v2]]) => f(v1, v2),
			at([NTranscode(f), [v]]) => f(v, Options.fromRefines(NTranscodeOptions, refines)),
			_ => throw "NYI"
		);
	}
}