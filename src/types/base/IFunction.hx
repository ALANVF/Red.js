package types.base;

enum QuotingKind {
	QVal;
	QGet;
	QLit;
}

@:structInit class _Refine {
	public final name: std.String;
	public final doc: Null<std.String> = null;
	public final args: _Args = [];
}

@:structInit class _Arg {
	public final name: std.String;
	public final quoting: QuotingKind;
	public final spec: Null<Block> = null;
	public final doc: Null<std.String> = null;
}

typedef _Refines = Array<_Refine>;

typedef _Args = Array<_Arg>;

interface IFunction extends IValue {
	public var doc(get, set): Null<std.String>;
	public var args(get, set): _Args;
	public var refines(get, set): _Refines;
	public var retSpec(get, set): Null<Block>;
	public var arity(get, never): Int;

	public function arityWithRefines(refines: Iterable<std.String>): Int;
}