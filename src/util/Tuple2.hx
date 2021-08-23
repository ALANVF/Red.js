package util;

abstract Tuple2<A, B>(Array<Dynamic>) {
	public var _1(get, never): A;
	public var _2(get, never): B;

	public inline function new(a: A, b: B) this = [a, b];

	inline function get__1(): A return this[0];
	inline function get__2(): B return this[1];
}