package types.base;

enum abstract CompareResult(Int) {
	final IsInvalid = -2;
	final IsLess = -1;
	final IsSame = 0;
	final IsMore = 1;
	
	@:op(A < B) inline function lt(other: CompareResult) return this < other.toInt();
	@:op(A <= B) inline function le(other: CompareResult) return this <= other.toInt();
	@:op(A > B) inline function gt(other: CompareResult) return this > other.toInt();
	@:op(A >= B) inline function ge(other: CompareResult) return this >= other.toInt();
	
	@:to inline function toInt() return this;
}