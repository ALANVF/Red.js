package util;

class MathTools {
	public static inline function iabs(_: Class<Math>, i: Int) return (untyped Math.abs(i) : Int);

#if js
	public static inline function clamp<T: Float>(_: Class<Math>, min: T, value: T, max: T): T {
		return js.Syntax.code("Math.max({0}, Math.min({1}, {2}))", min, value, max);
	}

	public static inline function max<T: Float>(value1: T, value2: T): T {
		return js.Syntax.code("Math.max({0}, {1})", value1, value2);
	}

	public static inline function min<T: Float>(value1: T, value2: T): T {
		return js.Syntax.code("Math.min({0}, {1})", value1, value2);
	}

	public static inline function sign<T: Float>(value: T): T {
		return js.Syntax.code("Math.sign({0})", value);
	}
#end
}