package types.base;

import haxe.ds.Option;

enum QuotingKind {
	QVal;
	QGet;
	QLit;
}

@:structInit class _Refine {
	public final name: std.String;
	public final doc: Option<std.String> = None;
	public final args: _Args = [];
}

@:structInit class _Arg {
	public final name: std.String;
	public final quoting: QuotingKind;
	public final spec: Option<Block> = None;
	public final doc: Option<std.String> = None;
}

typedef _Refines = Array<_Refine>;

typedef _Args = Array<_Arg>;

interface IFunction extends IValue {
	public var doc(get, set): Option<std.String>;
	public var args(get, set): _Args;
	public var refines(get, set): _Refines;
	public var retSpec(get, set): Option<Block>;
	public var arity(get, never): Int;

	public function arityWithRefines(refines: Iterable<std.String>): Int;
}