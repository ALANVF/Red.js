package util;

@:publicFields
class MathTools {
	static inline function iabs(_: Class<Math>, i: Int) return (untyped Math.abs(i) : Int);


	static inline function clamp<T: Float>(value: T, min: T, max: T): T {
		#if js
		return js.Syntax.code("Math.max({0}, Math.min({1}, {2}))", min, value, max);
		#else
		return cast Math.max(min, Math.min(value, max));
		#end
	}

	static inline function max<T: Float>(value1: T, value2: T): T {
		#if js
		return js.Syntax.code("Math.max({0}, {1})", value1, value2);
		#else
		return cast Math.max(value1, value2);
		#end
	}

	static inline function min<T: Float>(value1: T, value2: T): T {
		#if js
		return js.Syntax.code("Math.min({0}, {1})", value1, value2);
		#else
		return cast Math.min(value1, value2);
		#end
	}

	static inline function sign<T: Float>(value: T): Int {
		#if js
		return js.Syntax.code("Math.sign({0})", value);
		#else
		return value < 0 ? -1 : value > 0 ? 1 : 0;
		#end
	}

	static inline function compare<T: Float>(value1: T, value2: T): Int {
		return sign(value1 - value2);
	}

	static extern inline overload function asInt(bool: Bool): Int {
		#if js
		return js.Syntax.code("+{0}", bool);
		#else
		return bool ? 1 : 0;
		#end
	}
}