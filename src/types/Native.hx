package types;

import types.base.IFunction;
import types.base._Function;
import types.base._Number;
import types.base._String;
import types.base.Symbol;
import types.base._Block;
import types.base._NativeOptions;
import haxe.ds.Option;

private typedef CompareFn = (value1: Value, value2: Value) -> Logic;
private typedef SetOpFn = (set1: Value, set2: Value, options: NSetOpOptions) -> Value;
private typedef TrigFn = (value: _Number, options: NTrigOptions) -> Float;

enum NativeFn {
	NIf(fn: (cond: Value, thenBlk: Block) -> Value);
	NUnless(fn: (cond: Value, thenBlk: Block) -> Value);
	NEither(fn: (cond: Value, trueBlk: Block, falseBlk: Block) -> Value);
	NAny(fn: (conds: Block) -> Value);
	NAll(fn: (conds: Block) -> Value);
	NWhile(fn: (cond: Block, body: Block) -> Value);
	NUntil(fn: (body: Block) -> Value);
	NLoop(fn: (count: _Number, body: Block) -> Value);
	NRepeat(fn: (word: Word, value: _Number, body: Block) -> Value);
	NForever(fn: (body: Block) -> Value);
	NForeach(fn: (word: Value, series: Value, body: Block) -> Value);
	NForall(fn: (word: Word, body: Block) -> Value);
	NRemoveEach(fn: (word: Value, data: Value, body: Block) -> Value);
	NFunc(fn: (spec: Block, body: Block) -> Function);
	NFunction(fn: (spec: Block, body: Block, options: NFunctionOptions) -> Function);
	NDoes(fn: (body: Block) -> Function);
	NHas(fn: (vars: Block, body: Block) -> Function);
	NSwitch(fn: (value: Value, cases: Block, options: NSwitchOptions) -> Value);
	NCase(fn: (cases: Block, options: NCaseOptions) -> Value);
	NDo(fn: (value: Value, options: NDoOptions) -> Value);
	NGet(fn: (word: Value, options: NGetOptions) -> Value);
	NSet(fn: (word: Value, value: Value, options: NSetOptions) -> Value);
	NPrint(fn: (value: Value) -> Unset);
	NPrin(fn: (value: Value) -> Unset);
	NEqual_q(fn: CompareFn);
	NNotEqual_q(fn: CompareFn);
	NStrictEqual_q(fn: CompareFn);
	NLesser_q(fn: CompareFn);
	NGreater_q(fn: CompareFn);
	NLesserOrEqual_q(fn: CompareFn);
	NGreaterOrEqual_q(fn: CompareFn);
	NSame_q(fn: CompareFn);
	NNot(fn: (value: Value) -> Logic);
	NType_q(fn: (value: Value, options: NType_qOptions) -> Value);
	NReduce(fn: (value: Value, options: NReduceOptions) -> Value);
	NCompose(fn: (value: Block, options: NComposeOptions) -> Value);
	NStats(fn: (options: NStatsOptions) -> Value);
	NBind(fn: (word: Value, context: Value, options: NBindOptions) -> Value);
	NIn(fn: (object: Object, word: Symbol) -> Value);
	NParse(fn: (input: Value, rules: Block, options: NParseOptions) -> Value);
	NUnion(fn: SetOpFn);
	NIntersect(fn: SetOpFn);
	NUnique(fn: (set: Value, options: NSetOpOptions) -> Value);
	NDifference(fn: SetOpFn);
	NExclude(fn: SetOpFn);
	NComplement_q(fn: (bits: Bitset) -> Logic);
	NDehex(fn: (value: _String) -> String);
	NEnhex(fn: (value: _String) -> String);
	NNegative_q(fn: (number: Value) -> Logic);
	NPositive_q(fn: (number: Value) -> Logic);
	NMax(fn: (value1: Value, value2: Value) -> Value);
	NMin(fn: (value1: Value, value2: Value) -> Value);
	NShift(fn: (data: Integer, bits: Integer, options: NShiftOptions) -> Integer);
	NToHex(fn: (value: Integer, options: NToHexOptions) -> Issue);
	NSine(fn: TrigFn);
	NCosine(fn: TrigFn);
	NTangent(fn: TrigFn);
	NArcsine(fn: TrigFn);
	NArccosine(fn: TrigFn);
	NArctangent(fn: TrigFn);
	NArctangent2(fn: (y: _Number, x: _Number, options: NTrigOptions) -> Float);
	NNan_q(fn: (value: _Number) -> Logic);
	NLog2(fn: (value: _Number) -> Float);
	NLog10(fn: (value: _Number) -> Float);
	NLogE(fn: (value: _Number) -> Float);
	NExp(fn: (value: _Number) -> Float);
	NSquareRoot(fn: (value: _Number) -> Float);
	NConstruct(fn: (block: Block, options: NConstructOptions) -> Object);
	NValue_q(fn: (value: Value) -> Logic);
	NTry(fn: (block: Block, options: NTryOptions) -> Value);
	NUppercase(fn: (string: Value, options: NChangeCaseOptions) -> Value);
	NLowercase(fn: (string: Value, options: NChangeCaseOptions) -> Value);
	NAsPair(fn: (x: _Number, y: _Number) -> Pair);
	NAsMoney(fn: (currency: Word, amount: _Number) -> Money);
	NBreak(fn: (options: NBreakOptions) -> Unset);
	NContinue(fn: () -> Unset);
	NExit(fn: () -> Unset);
	NReturn(fn: (value: Value) -> Unset);
	NThrow(fn: (value: Value, options: NThrowOptions) -> Unset);
	NCatch(fn: (block: Block, options: NCatchOptions) -> Value);
	NExtend(fn: (obj: Value, spec: Value, options: NExtendOptions) -> Value);
	NDebase(fn: (value: String, options: NBaseOptions) -> Value);
	NToLocalFile(fn: (path: _String, options: NToLocalFileOptions) -> String);
	NWait(fn: (value: Value, options: NWaitOptions) -> None);
	NChecksum(fn: (data: Value, method: Word, options: NChecksumOptions) -> Value);
	NUnset(fn: (word: Value) -> Unset);
	NNewLine(fn: (position: _Block, value: Logic, options: NNewLineOptions) -> _Block);
	NNewLine_q(fn: (position: _Block) -> Logic);
	NEnbase(fn: (value: Value, options: NBaseOptions) -> Value);
	NContext_q(fn: (word: Symbol) -> Value);
	NSetEnv(fn: (var_: Value, value: Value) -> Value);
	NGetEnv(fn: (var_: Value) -> Value);
	NListEnv(fn: () -> Map);
	NNow(fn: (options: NNowOptions) -> Value);
	NSign_q(fn: (number: Value) -> Integer);
	NAs(fn: (type: Value, spec: Value) -> Value);
	NCall(fn: (cmd: _String, options: NCallOptions) -> Integer);
	NZero_q(fn: (value: Value) -> Logic);
	NSize_q(fn: (file: File) -> Value);
	NBrowse(fn: (url: _String) -> Unset);
	NCompress(fn: (data: Value, options: NCompressOptions) -> Value);
	NDecompress(fn: (data: Binary, options: NDecompressOptions) -> Value);
	NRecycle(fn: (options: NRecycleOptions) -> Unset);
	NTranscode(fn: (src: Value, options: NTranscodeOptions) -> Value);
}

class Native extends _Function {
	//public static final NATIVE_FUNCS: Dict<std.String, NativeFn> = [];

	public final fn: NativeFn;

	public function new(doc: Null<std.String>, params: _Params, refines: _Refines, retSpec: Null<Block>, fn: NativeFn) {
		super(doc, params, refines, retSpec);
		this.fn = fn;
	}
}