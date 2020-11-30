package experimental.jsDialect;

import haxe.ds.Option;
import experimental.jsDialect.Statement;

enum Expr {
	EName(name: String);
	EThis;
	ESuper;
	ENull;
	EUndefined;
	ENumber(number: Float);
	EBigInt(bigInt: String);
	EString(string: String);
	EBoolean(boolean: Bool);
	EArray(exprs: Array<Expr>);
	EObject(pairs: Array<{k: Expr, v: Option<Expr>}>);
	ERegExp(regexp: String);
	
	EAccess(expr: Expr, name: String);
	//ETryAccess
	ECall(caller: Expr, args: Array<Expr>);
	//ETryCall
	ENew(type: Expr, args: Array<Expr>);

	EFunction(name: Option<String>, params: Array<Expr>, body: Block);
	EAsyncFunction(name: Option<String>, params: Array<Expr>, body: Block);
	EGeneratorFunction(name: Option<String>, params: Array<Expr>, body: Block);

	EClosure(params: Array<Expr>, body: Block);
	EAsyncClosure(params: Array<Expr>, body: Block);

	//EClass(name: Option<String>, parent: Option<Expr>, body: Array<Statement?>);

	EAwait(expr: Expr);
	EDelete(expr: Expr);
	EVoid(expr: Expr);
	ETypeof(expr: Expr);
	EYield(expr: Expr);
	EYieldAll(expr: Expr);

	// ...

	EAssign(left: Expr, right: Expr);
	EInfix(left: Expr, op: String, right: Expr);
	EPrefix(op: String, right: Expr);
	ESuffix(left: Expr, op: String);

	// ...

	EIf(cond: Expr, blk: Block);
	EEither(cond: Expr, thenBlk: Block, elseBlk: Block);
	ECase(cases: Array<{cond: Expr, blk: Block}>);
	ESwitch(expr: Expr, cases: Array<{expr: Expr, blk: Block, fallThrough: Bool}>, defaultBlk: Option<Block>);

	EDo(blk: Block);

	// ...

	EJs(code: String);
}