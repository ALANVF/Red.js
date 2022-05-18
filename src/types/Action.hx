package types;

import types.base.IFunction;
import types.base._Function;
import types.base._ActionOptions;
import types.base._Path;
import types.base._Number;
import types.base.ComparisonOp;
import haxe.ds.Option;

private typedef Fn1 = (value: Value) -> Value;
private typedef LogicFn1 = (value: Value) -> Logic;
private typedef Fn2 = (value1: Value, value2: Value) -> Value;

enum ActionFn {
	AMake(fn: (type: Value, spec: Value) -> Value);
	ARandom(fn: (value: Value, options: ARandomOptions) -> Value);
	AReflect(fn: (value: Value, field: Word) -> Value);
	ATo(fn: (type: Value, spec: Value) -> Value);
	AForm(fn: (value: Value, options: AFormOptions) -> String);
	AMold(fn: (value: Value, options: AMoldOptions) -> String);
	AModify(fn: (tparamet: Value, field: Word, value: Value, options: AModifyOptions) -> Value);
	
	AEvalPath(fn: (parent: Value, element: Value, value: Null<Value>, path: _Path, isCase: Bool) -> Value);
	ACompare(fn: (value1: Value, value2: Value, op: ComparisonOp) -> Logic);

	/*-- Scalar actions --*/
	AAbsolute(fn: Fn1);
	AAdd(fn: Fn2);
	ADivide(fn: Fn2);
	AMultiply(fn: Fn2);
	ANegate(fn: Fn1);
	APower(fn: (number: _Number, exponent: _Number) -> _Number);
	ARemainder(fn: Fn2);
	ARound(fn: (n: Value, options: ARoundOptions) -> Value);
	ASubtract(fn: Fn2);
	AEven_q(fn: LogicFn1);
	AOdd_q(fn: LogicFn1);
	
	/*-- Bitwise actions --*/
	AAnd(fn: Fn2);
	AComplement(fn: Fn1);
	AOr(fn: Fn2);
	AXor(fn: Fn2);
	
	/*-- Series actions --*/
	AAppend(fn: (series: Value, value: Value, options: AAppendOptions) -> Value);
	AAt(fn: (series: Value) -> Value);
	ABack(fn: (series: Value) -> Value);
	AChange(fn: (series: Value, value: Value, options: AChangeOptions) -> Value);
	AClear(fn: (series: Value) -> Value);
	ACopy(fn: (value: Value, options: ACopyOptions) -> Value);
	AFind(fn: (series: Value, value: Value, options: AFindOptions) -> Value);
	AHead(fn: (series: Value) -> Value);
	AHead_q(fn: (series: Value) -> Logic);
	AIndex_q(fn: (series: Value) -> Integer);
	AInsert(fn: (series: Value, value: Value, options: AInsertOptions) -> Value);
	ALength_q(fn: (series: Value) -> Value);
	AMove(fn: (origin: Value, tparamet: Value, options: AMoveOptions) -> Value);
	ANext(fn: (series: Value) -> Value);
	APick(fn: (series: Value, index: Value) -> Value);
	APoke(fn: (series: Value, index: Value, value: Value) -> Value);
	APut(fn: (series: Value, key: Value, value: Value, options: APutOptions) -> Value);
	ARemove(fn: (series: Value, options: ARemoveOptions) -> Value);
	AReverse(fn: (series: Value, options: AReverseOptions) -> Value);
	ASelect(fn: (series: Value, value: Value, options: ASelectOptions) -> Value);
	ASort(fn: (series: Value, options: ASortOptions) -> Value);
	ASkip(fn: (series: Value, offset: Value) -> Value);
	ASwap(fn: (series1: Value, series2: Value) -> Value);
	ATail(fn: (series: Value) -> Value);
	ATail_q(fn: (series: Value) -> Logic);
	ATake(fn: (series: Value, options: ATakeOptions) -> Value);
	ATrim(fn: (series: Value, options: ATrimOptions) -> Value);
	
	/*-- I/O actions --*/
	ACreate(fn: (port: Value) -> Value);
	//AClose(fn: (port: Port) -> Value);
	ADelete(fn: (file: Value) -> Value);
	AOpen(fn: (port: Value, options: AOpenOptions) -> Value);
	//AOpen_q(fn: (port: Port) -> Logic);
	AQuery(fn: (tparamet: Value) -> Value);
	ARead(fn: (source: Value, options: AReadOptions) -> Value);
	ARename(fn: (from: Value, to: Value) -> Value);
	//AUpdate(fn: (port: Port) -> Value);
	AWrite(fn: (destination: Value, data: Value, options: AWriteOptions) -> Value);
	
	//AApply(fn: (???) -> ???);
}

class Action extends _Function {
	//public static final ACTION_FUNCS: Dict<std.String, ActionFn> = [];

	public final fn: ActionFn;

	public function new(doc: Null<std.String>, params: _Params, refines: _Refines, retSpec: Null<Block>, fn: ActionFn) {
		super(doc, params, refines, retSpec);
		this.fn = fn;
	}
}