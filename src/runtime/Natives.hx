package runtime;

import types.Word;
import types.Block;
import types.base._NativeOptions;
import types.base.Options;
import types.base._Number;
import types.base._String;
import types.base._Block;
import types.base.Symbol;
import types.Value;
import types.Native;
import types.Bitset;
import types.Integer;
import types.Logic;

class Natives {
	public static function callNative(native: Native, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		return Util._match([native.fn, args],
			at([NIf(f) | NUnless(f), [cond, b is Block]]) => f(cond, b),
			at([NEither(f), [cond, tb is Block, fb is Block]]) => f(cond, tb, fb),
			at([( NAny(f)
				| NAll(f)
				| NUntil(f)
				| NForever(f)
				| NDoes(f)
			), [b is Block]]) => f(b),
			at([NWhile(f), [cond is Block, body is Block]]) => f(cond, body),
			at([NLoop(f), [n is _Number, b is Block]]) => f(n, b),
			at([NRepeat(f), [w is Word, n is _Number, b is Block]]) => f(w, n, b),
			at([NForeach(f) | NRemoveEach(f), [word, series, b is Block]]) => f(word, series, b),
			at([NForall(f), [word is Word, body is Block]]) => f(word, body),
			at([NFunc(f) | NHas(f), [spec is Block, body is Block]]) => f(spec, body),
			at([NFunction(f), [spec is Block, body is Block]]) => f(spec, body, Options.fromRefines(NFunctionOptions, refines)),
			at([NSwitch(f), [v, cs is Block]]) => f(v, cs, Options.fromRefines(NSwitchOptions, refines)),
			at([NCase(f), [cs is Block]]) => f(cs, Options.fromRefines(NCaseOptions, refines)),
			at([NDo(f), [v]]) => f(v, Options.fromRefines(NDoOptions, refines)),
			at([NReduce(f), [v]]) => f(v, Options.fromRefines(NReduceOptions, refines)),
			at([NCompose(f), [b is Block]]) => f(b, Options.fromRefines(NComposeOptions, refines)),
			at([NGet(f), [w]]) => f(w, Options.fromRefines(NGetOptions, refines)),
			at([NSet(f), [w, v]]) => f(w, v, Options.fromRefines(NSetOptions, refines)),
			at([NPrint(f) | NPrin(f), [v]]) => f(v),
			at([( NNot(f)
				| NNegative_q(f) | NPositive_q(f) | NZero_q(f)
				| NValue_q(f)
			), [v]]) => f(v),
			at([( NEqual_q(f)
				| NNotEqual_q(f)
				| NStrictEqual_q(f)
				| NLesser_q(f)
				| NGreater_q(f)
				| NLesserOrEqual_q(f)
				| NGreaterOrEqual_q(f)
				| NSame_q(f)
			), [v1, v2]]) => f(v1, v2),
			at([NType_q(f), [v]]) => f(v, Options.fromRefines(NType_qOptions, refines)),
			at([NStats(f), []]) => f(Options.fromRefines(NStatsOptions, refines)),
			at([NBind(f), [w, c]]) => f(w, c, Options.fromRefines(NBindOptions, refines)),
			at([NIn(f), [o is types.Object, s is types.base.Symbol]]) => f(o, s),
			at([NUnion(f) | NIntersect(f) | NExclude(f) | NDifference(f), [v1, v2]]) =>
				f(v1, v2, Options.fromRefines(NSetOpOptions, refines)),
			at([NComplement_q(f), [b is Bitset]]) => f(b),
			at([NDehex(f) | NEnhex(f), [s is _String]]) => f(s),
			at([NMin(f) | NMax(f), [v1, v2]]) => f(v1, v2),
			at([NShift(f), [d is Integer, b is Integer]]) => f(d, b, Options.fromRefines(NShiftOptions, refines)),
			at([NToHex(f), [i is Integer]]) => f(i, Options.fromRefines(NToHexOptions, refines)),
			at([( NSine(f)    | NCosine(f)    | NTangent(f)
				| NArcsine(f) | NArccosine(f) | NArctangent(f)
			), [n is _Number]]) => f(n, Options.fromRefines(NTrigOptions, refines)),
			at([NArctangent2(f), [y is _Number, x is _Number]]) => f(y, x, Options.fromRefines(NTrigOptions, refines)),
			at([NNan_q(f), [n is _Number]]) => f(n),
			at([NLog2(f) | NLog10(f) | NLogE(f) | NExp(f) | NSquareRoot(f), [n is _Number]]) => f(n),
			at([NConstruct(f), [b is Block]]) => f(b, Options.fromRefines(NConstructOptions, refines)),
			at([NTry(f), [b is Block]]) => f(b, Options.fromRefines(NTryOptions, refines)),
			at([NUppercase(f) | NLowercase(f), [s]]) => f(s, Options.fromRefines(NChangeCaseOptions, refines)),
			at([NAsPair(f), [
				x is Integer | x is types.Float,
				y is Integer | y is types.Float
			]]) => f(x, y),
			at([NBreak(f), []]) => f(Options.fromRefines(NBreakOptions, refines)),
			at([NReturn(f) | NUnset(f), [v]]) => f(v),
			at([NExit(f) | NContinue(f), []]) => f(),
			at([NThrow(f), [v]]) => f(v, Options.fromRefines(NThrowOptions, refines)),
			at([NCatch(f), [b is Block]]) => f(b, Options.fromRefines(NCatchOptions, refines)),
			at([NExtend(f), [o, s]]) => f(o, s, Options.fromRefines(NExtendOptions, refines)),
			at([NNewLine(f), [l is _Block, c is Logic]]) => f(l, c, Options.fromRefines(NNewLineOptions, refines)),
			at([NNewLine_q(f), [l is _Block]]) => f(l),
			at([NContext_q(f), [w is Symbol]]) => f(w),
			at([NNow(f), []]) => f(Options.fromRefines(NNowOptions, refines)),
			at([NSign_q(f), [n]]) => f(n),
			at([NTranscode(f), [v]]) => f(v, Options.fromRefines(NTranscodeOptions, refines)),
			_ => throw "NYI"
		);
	}
}