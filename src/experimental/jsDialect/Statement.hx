package experimental.jsDialect;

import haxe.ds.Option;

enum VarKind {
	VKVar;
	VKLet;
	VKConst;
}

typedef Block = Array<Statement>;

enum Statement {
	SExpr(expr: Expr);

	SVarDecl(kind: VarKind, name: String, value: Option<Expr>);
	//SVarDecls(kind: VarKind, vars: Array<...>);
	SFunction(name: String, params: Array<Expr>, body: Block);
	SAsyncFunction(name: String, params: Array<Expr>, body: Block);
	SGeneratorFunction(name: String, params: Array<Expr>, body: Block);

	SIf(cond: Expr, blk: Block);
	SEither(cond: Expr, thenBlk: Block, elseBlk: Block);
	SCase(cases: Array<{cond: Expr, blk: Block}>);
	SSwitch(expr: Expr, cases: Array<{expr: Expr, blk: Block, fallThrough: Bool}>, defaultBlk: Option<Block>);

	SWhile(cond: Expr, blk: Block);
	SDoWhile(blk: Block, cond: Expr);
	SFor(init: Expr, cond: Expr, incr: Expr);
	SForIn(kind: Option<VarKind>, loopVar: Expr, value: Expr, blk: Block);
	SForOf(kind: Option<VarKind>, loopVar: Expr, value: Expr, blk: Block);
	SForAwaitOf(kind: Option<VarKind>, loopVar: Expr, value: Expr, blk: Block);

	SBreak;
	SBreakLabel(label: String);
	SContinue;
	SContinueLabel(label: String);
	SReturn(expr: Option<Expr>);
	SThrow(expr: Expr);

	STry(tryBlock: Block);
	STryCatch(tryBlock: Block, catchVar: String, catchBlock: Block);
	STryFinally(tryBlock: Block, finallyBlock: Block);
	STryCatchFinally(tryBlock: Block, catchVar: String, catchBlock: Block, finallyBlock: Block);

	SWith(expr: Expr, block: Block);

	//SImport
	//SExport
	//SRequire

	SLabel(name: String, stmt: Statement);

	//SClass

	SJs(code: String);
}