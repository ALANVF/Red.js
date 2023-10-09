package types.base;

enum QuotingKind {
	QVal;
	QGet;
	QLit;
}

@:structInit class _Refine {
	public final name: std.String;
	public final doc: Null<std.String> = null;
	public final params: _Params = [];
}

@:structInit class _Param {
	public final name: std.String;
	public final quoting: QuotingKind;
	public final spec: Null<Block> = null;
	public final doc: Null<std.String> = null;
}

typedef _Refines = Array<_Refine>;

typedef _Params = Array<_Param>;

interface IFunction extends IValue {
	public var origSpec(get, set): Block;
	public var doc(get, set): Null<std.String>;
	public var params(get, set): _Params;
	public var refines(get, set): _Refines;
	public var retSpec(get, set): Null<Block>;
	public var arity(get, never): Int;

	public function arityWithRefines(refines: Iterable<std.String>): Int;
	public function findRefine(w: _Word): Null<_Refine>;
}