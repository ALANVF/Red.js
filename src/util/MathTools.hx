package util;

@:publicFields
class MathTools {
	static inline function iabs(_: Class<Math>, i: Int) return (untyped Math.abs(i) : Int);

#if js
	static inline function clamp<T: Float>(_: Class<Math>, min: T, value: T, max: T): T {
		return js.Syntax.code("Math.max({0}, Math.min({1}, {2}))", min, value, max);
	}

	static inline function max<T: Float>(value1: T, value2: T): T {
		return js.Syntax.code("Math.max({0}, {1})", value1, value2);
	}

	static inline function min<T: Float>(value1: T, value2: T): T {
		return js.Syntax.code("Math.min({0}, {1})", value1, value2);
	}

	static inline function sign<T: Float>(value: T): Int {
		return js.Syntax.code("Math.sign({0})", value);
	}

	static inline function compare<T: Float>(value1: T, value2: T): Int {
		return sign(value1 - value2);
	}

	static extern inline overload function asInt(bool: Bool): Int {
		return js.Syntax.code("+{0}", bool);
	}
#end
}