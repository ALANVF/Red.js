package util;

#if js
using js.lib.intl.NumberFormat;

@:publicFields
@:native("BigInt")
private extern class _BigInt {
	@:selfCall
	@:overload(function(v: String):Void {})
	@:overload(function(v: Int):Void {})
	@:overload(function(v: Bool):Void {})
	function new(v: BigInt);

	static extern function asIntN(bits: Int, bigint: BigInt): BigInt;
	static extern function asUintN(bits: Int, bigint: BigInt): BigInt;

	extern function toString(?radix: Int): String;

	@:overload(function(?locales: Array<String>, ?options: NumberFormatOptions): String {})
	extern function toLocaleString(?locales: String, ?options: NumberFormatOptions): String;

	extern function valueOf(): BigInt;
}

@:forward
@:forward.new
@:forwardStatics
@:publicFields
abstract BigInt(_BigInt) from _BigInt {
	inline function toInt(): Int return js.Syntax.code("Number({0})", this);
	
	inline function abs(): BigInt return abstract < 0 ? -abstract : abstract;

	inline function min(other: BigInt) return abstract < other ? abstract : other;
	inline function max(other: BigInt) return abstract > other ? abstract : other;

	@:op(-A) inline function neg(): BigInt return js.Syntax.code("-{0}", this);
	@:op(~A) inline function compl(): BigInt return js.Syntax.code("~{0}", this);
	@:op(++A) inline function preIncr(): BigInt return js.Syntax.code("++{0}", this);
	@:op(--A) inline function preDecr(): BigInt return js.Syntax.code("--{0}", this);
	@:op(A++) inline function postIncr(): BigInt return js.Syntax.code("{0}++", this);
	@:op(A--) inline function postDecr(): BigInt return js.Syntax.code("{0}--", this);

	@:op(A + B) inline function add(other: BigInt): BigInt return js.Syntax.code("({0} + {1})", this, other);
	@:op(A - B) inline function sub(other: BigInt): BigInt return js.Syntax.code("({0} - {1})", this, other);
	@:op(A * B) inline function mul(other: BigInt): BigInt return js.Syntax.code("({0} * {1})", this, other);
	@:op(A / B) inline function div(other: BigInt): BigInt return js.Syntax.code("({0} / {1})", this, other);
	@:op(A % B) inline function mod(other: BigInt): BigInt return js.Syntax.code("({0} % {1})", this, other);
	inline function pow(other: BigInt): BigInt return js.Syntax.code("({0} ** {1})", this, other);
	@:op(A & B) inline function and(other: BigInt): BigInt return js.Syntax.code("({0} & {1})", this, other);
	@:op(A | B) inline function or(other: BigInt): BigInt return js.Syntax.code("({0} | {1})", this, other);
	@:op(A ^ B) inline function xor(other: BigInt): BigInt return js.Syntax.code("({0} ^ {1})", this, other);
	@:op(A << B) inline function shl(other: BigInt): BigInt return js.Syntax.code("({0} << {1})", this, other);
	@:op(A >> B) inline function shr(other: BigInt): BigInt return js.Syntax.code("({0} >> {1})", this, other);

	@:op(A += B) inline function addEq(other: BigInt): BigInt return js.Syntax.code("{0} += {1}", this, other);
	@:op(A -= B) inline function subEq(other: BigInt): BigInt return js.Syntax.code("{0} -= {1}", this, other);
	@:op(A *= B) inline function mulEq(other: BigInt): BigInt return js.Syntax.code("{0} *= {1}", this, other);
	@:op(A /= B) inline function divEq(other: BigInt): BigInt return js.Syntax.code("{0} /= {1}", this, other);
	@:op(A %= B) inline function modEq(other: BigInt): BigInt return js.Syntax.code("{0} %= {1}", this, other);
	@:op(A &= B) inline function andEq(other: BigInt): BigInt return js.Syntax.code("{0} &= {1}", this, other);
	@:op(A |= B) inline function orEq(other: BigInt): BigInt return js.Syntax.code("{0} |= {1}", this, other);
	@:op(A ^= B) inline function xorEq(other: BigInt): BigInt return js.Syntax.code("{0} ^= {1}", this, other);
	@:op(A <<= B) inline function shlEq(other: BigInt): BigInt return js.Syntax.code("{0} <<= {1}", this, other);
	@:op(A >>= B) inline function shrEq(other: BigInt): BigInt return js.Syntax.code("{0} >>= {1}", this, other);

	@:op(A == B) static extern overload inline function eq(a: BigInt, b: BigInt): Bool return js.Syntax.code("({0} == {1})", a, b);
	@:op(A == B) static extern overload inline function eq(a: Int, b: BigInt): Bool return js.Syntax.code("({0} == {1})", a, b);
	@:op(A == B) static extern overload inline function eq(a: BigInt, b: Int): Bool return js.Syntax.code("({0} == {1})", a, b);

	@:op(A != B) static extern overload inline function ne(a: BigInt, b: BigInt): Bool return js.Syntax.code("({0} != {1})", a, b);
	@:op(A != B) static extern overload inline function ne(a: Int, b: BigInt): Bool return js.Syntax.code("({0} != {1})", a, b);
	@:op(A != B) static extern overload inline function ne(a: BigInt, b: Int): Bool return js.Syntax.code("({0} != {1})", a, b);

	@:op(A < B) static extern overload inline function lt(a: BigInt, b: BigInt): Bool return js.Syntax.code("({0} < {1})", a, b);
	@:op(A < B) static extern overload inline function lt(a: Int, b: BigInt): Bool return js.Syntax.code("({0} < {1})", a, b);
	@:op(A < B) static extern overload inline function lt(a: BigInt, b: Int): Bool return js.Syntax.code("({0} < {1})", a, b);

	@:op(A <= B) static extern overload inline function le(a: BigInt, b: BigInt): Bool return js.Syntax.code("({0} <= {1})", a, b);
	@:op(A <= B) static extern overload inline function le(a: Int, b: BigInt): Bool return js.Syntax.code("({0} <= {1})", a, b);
	@:op(A <= B) static extern overload inline function le(a: BigInt, b: Int): Bool return js.Syntax.code("({0} <= {1})", a, b);

	@:op(A > B) static extern overload inline function gt(a: BigInt, b: BigInt): Bool return js.Syntax.code("({0} > {1})", a, b);
	@:op(A > B) static extern overload inline function gt(a: Int, b: BigInt): Bool return js.Syntax.code("({0} > {1})", a, b);
	@:op(A > B) static extern overload inline function gt(a: BigInt, b: Int): Bool return js.Syntax.code("({0} > {1})", a, b);
	@:op(A >= B) static extern overload inline function ge(a: BigInt, b: BigInt): Bool return js.Syntax.code("({0} >= {1})", a, b);
	@:op(A >= B) static extern overload inline function ge(a: Int, b: BigInt): Bool return js.Syntax.code("({0} >= {1})", a, b);
	@:op(A >= B) static extern overload inline function ge(a: BigInt, b: Int): Bool return js.Syntax.code("({0} >= {1})", a, b);
}
#else
typedef BigInt = Dynamic;
#end

/*
@:publicFields
@:native("BigInt")
@:coreType extern abstract BigInt {
	@:selfCall
	@:overload(function(v: String):Void {})
	@:overload(function(v: Int):Void {})
	@:overload(function(v: Bool):Void {})
	function new(v: BigInt);

	static extern function asIntN(bits: Int, bigint: BigInt): BigInt;
	static extern function asUintN(bits: Int, bigint: BigInt): BigInt;
	
	extern function toString(?radix: Int): String;

	@:overload(function(?locales: Array<String>, ?options: NumberFormatOptions): String {})
	extern function toLocaleString(?locales: String, ?options: NumberFormatOptions): String;

	extern function valueOf(): BigInt;

	inline function toInt(): Int return js.Syntax.code("Number({0})", this);

	inline function abs(): BigInt return js.Syntax.code("Math.abs({0})", this);

	@:op(-A) static function neg(a: BigInt): BigInt;
	@:op(~A) static function compl(a: BigInt): BigInt;
	@:op(++A) static function preIncr(a: BigInt): BigInt;
	@:op(--A) static function preDecr(a: BigInt): BigInt;
	@:op(A++) static function postIncr(a: BigInt): BigInt;
	@:op(A--) static function postDecr(a: BigInt): BigInt;

	@:op(A + B) static function add(a: BigInt, b: BigInt): BigInt;
	@:op(A - B) static function sub(a: BigInt, b: BigInt): BigInt;
	@:op(A * B) static function mul(a: BigInt, b: BigInt): BigInt;
	@:op(A / B) static function div(a: BigInt, b: BigInt): BigInt;
	@:op(A % B) static function mod(a: BigInt, b: BigInt): BigInt);
	inline function pow(other: BigInt): BigInt return js.Syntax.code("({0} ** {1})", this, other);
	@:op(A & B) static function and(a: BigInt, b: BigInt): BigInt;
	@:op(A | B) static function or(a: BigInt, b: BigInt): BigInt;
	@:op(A ^ B) static function xor(a: BigInt, b: BigInt): BigInt;
	@:op(A << B) static function shl(a: BigInt, b: BigInt): BigInt;
	@:op(A >> B) static function shr(a: BigInt, b: BigInt): BigInt;

	@:op(A == B) static function eq(a: Int, b: BigInt): Bool;
	@:op(A == B) static function eq1(a: BigInt, b: Int): Bool;
	@:op(A == B) static function eq2(a: BigInt, b: BigInt): Bool;

	@:op(A != B) static function ne(a: Int, b: BigInt): Bool;
	@:op(A != B) static function ne1(a: BigInt, b: Int): Bool;
	@:op(A != B) static function ne2(a: BigInt, b: BigInt): Bool;

	@:op(A < B) static function lt(a: Int, b: BigInt): Bool;
	@:op(A < B) static function lt1(a: BigInt, b: Int): Bool;
	@:op(A < B) static function lt2(a: BigInt, b: BigInt): Bool;

	@:op(A <= B) static function le(a: Int, b: BigInt): Bool;
	@:op(A <= B) static function le1(a: BigInt, b: Int): Bool;
	@:op(A <= B) static function le2(a: BigInt, b: BigInt): Bool;

	@:op(A > B) static function gt(a: Int, b: BigInt): Bool;
	@:op(A > B) static function gt1(a: BigInt, b: Int): Bool;
	@:op(A > B) static function gt2(a: BigInt, b: BigInt): Bool;

	@:op(A >= B) static function ge(a: Int, b: BigInt): Bool;
	@:op(A >= B) static function ge1(a: BigInt, b: Int): Bool;
	@:op(A >= B) static function ge2(a: BigInt, b: BigInt): Bool;
}
*/