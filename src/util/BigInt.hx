package util;

using js.lib.intl.NumberFormat;

@:publicFields
@:native("BigInt")
extern class _BigInt {
	@:selfCall
	@:overload(function(v: String):Void {})
	@:overload(function(v: Int):Void {})
	@:overload(function(v: Bool):Void {})
	function new(v: BigInt);

	static extern function asIntN(bits: Int, bigint: BigInt): BigInt;
	static extern function asUintN(bits: Int, bigint: BigInt): BigInt;

	extern function toString(?base: Int): String;

	@:overload(function(?locales: Array<String>, ?options: NumberFormatOptions): String {})
	extern function toLocaleString(?locales: String, ?options: NumberFormatOptions): String;

	extern function valueOf(): BigInt;
}

@:forward
@:forward.new
@:forwardStatics
@:publicFields
abstract BigInt(_BigInt) from _BigInt {
	@:op(-A) inline function neg(): BigInt return js.Syntax.code("-{0}", this);
	@:op(~A) inline function compl(): BigInt return js.Syntax.code("~{0}", this);
	@:op(++A) inline function preIncr(): BigInt return js.Syntax.code("++{0}", this);
	@:op(--A) inline function preDecr(): BigInt return js.Syntax.code("--{0}", this);
	@:op(A++) inline function postIncr(): BigInt return js.Syntax.code("{0}++", this);
	@:op(A--) inline function postDecr(): BigInt return js.Syntax.code("{0}--", this);

	@:op(A + B) inline function add(other: BigInt): BigInt return js.Syntax.code("{0} + {1}", this, other);
	@:op(A - B) inline function sub(other: BigInt): BigInt return js.Syntax.code("{0} - {1}", this, other);
	@:op(A * B) inline function mul(other: BigInt): BigInt return js.Syntax.code("{0} * {1}", this, other);
	@:op(A / B) inline function div(other: BigInt): BigInt return js.Syntax.code("{0} / {1}", this, other);
	inline function pow(other: BigInt): BigInt return js.Syntax.code("{0} ** {1}", this, other);
	@:op(A & B) inline function and(other: BigInt): BigInt return js.Syntax.code("{0} & {1}", this, other);
	@:op(A | B) inline function or(other: BigInt): BigInt return js.Syntax.code("{0} | {1}", this, other);
	@:op(A ^ B) inline function xor(other: BigInt): BigInt return js.Syntax.code("{0} ^ {1}", this, other);
	@:op(A << B) inline function shl(other: BigInt): BigInt return js.Syntax.code("{0} << {1}", this, other);
	@:op(A >> B) inline function shr(other: BigInt): BigInt return js.Syntax.code("{0} >> {1}", this, other);

	@:op(A == B) static extern overload inline function eq(a: BigInt, b: BigInt): Bool return js.Syntax.code("{0} == {1}", a, b);
	@:op(A == B) static extern overload inline function eq(a: Int, b: BigInt): Bool return js.Syntax.code("{0} == {1}", a, b);
	@:op(A == B) static extern overload inline function eq(a: BigInt, b: Int): Bool return js.Syntax.code("{0} == {1}", a, b);

	@:op(A != B) static extern overload inline function ne(a: BigInt, b: BigInt): Bool return js.Syntax.code("{0} != {1}", a, b);
	@:op(A != B) static extern overload inline function ne(a: Int, b: BigInt): Bool return js.Syntax.code("{0} != {1}", a, b);
	@:op(A != B) static extern overload inline function ne(a: BigInt, b: Int): Bool return js.Syntax.code("{0} != {1}", a, b);

	@:op(A < B) static extern overload inline function lt(a: BigInt, b: BigInt): Bool return js.Syntax.code("{0} < {1}", a, b);
	@:op(A < B) static extern overload inline function lt(a: Int, b: BigInt): Bool return js.Syntax.code("{0} < {1}", a, b);
	@:op(A < B) static extern overload inline function lt(a: BigInt, b: Int): Bool return js.Syntax.code("{0} < {1}", a, b);

	@:op(A <= B) static extern overload inline function le(a: BigInt, b: BigInt): Bool return js.Syntax.code("{0} <= {1}", a, b);
	@:op(A <= B) static extern overload inline function le(a: Int, b: BigInt): Bool return js.Syntax.code("{0} <= {1}", a, b);
	@:op(A <= B) static extern overload inline function le(a: BigInt, b: Int): Bool return js.Syntax.code("{0} <= {1}", a, b);

	@:op(A > B) static extern overload inline function gt(a: BigInt, b: BigInt): Bool return js.Syntax.code("{0} > {1}", a, b);
	@:op(A > B) static extern overload inline function gt(a: Int, b: BigInt): Bool return js.Syntax.code("{0} > {1}", a, b);
	@:op(A > B) static extern overload inline function gt(a: BigInt, b: Int): Bool return js.Syntax.code("{0} > {1}", a, b);
	@:op(A >= B) static extern overload inline function ge(a: BigInt, b: BigInt): Bool return js.Syntax.code("{0} >= {1}", a, b);
	@:op(A >= B) static extern overload inline function ge(a: Int, b: BigInt): Bool return js.Syntax.code("{0} >= {1}", a, b);
	@:op(A >= B) static extern overload inline function ge(a: BigInt, b: Int): Bool return js.Syntax.code("{0} >= {1}", a, b);
}