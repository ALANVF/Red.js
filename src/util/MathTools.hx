package util;

class MathTools {
	public static inline function iabs(_: Class<Math>, i: Int) return (untyped Math.abs(i) : Int);

#if js
	public static inline function clamp<T: Float>(_: Class<Math>, min: T, value: T, max: T): T {
		return js.Syntax.code("Math.max({0}, Math.min({1}, {2}))", min, value, max);
	}
#end
}