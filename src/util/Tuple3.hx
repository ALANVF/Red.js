package util;

abstract Tuple3<A, B, C>(Array<Dynamic>) {
	public var _1(get, never): A;
	public var _2(get, never): B;
	public var _3(get, never): C;

	public inline function new(a: A, b: B, c: C) this = [a, b, c];

	inline function get__1(): A return this[0];
	inline function get__2(): B return this[1];
	inline function get__3(): C return this[2];
}