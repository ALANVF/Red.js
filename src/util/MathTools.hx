package util;

@:publicFields
class MathTools {
	private static inline final LOG2E = 1.4426950408889634;

	static inline function iabs(_: Class<Math>, i: Int) return (untyped Math.abs(i) : Int);


	static inline function log2(_: Class<Math>, value: Float): Float {
		#if js
		return js.lib.Math.log2(value);
		#else
		return Math.log(value) * LOG2E;
		#end
	}

	static inline function trunc(_: Class<Math>, value: Float): Int {
		#if js
		return js.lib.Math.trunc(value);
		#else
		return _trunc(value);
		#end
	}
	#if !js
	private static function _trunc(value: Float): Int {
		final d = Math.floor(Math.abs(value));
		return if(value < 0) 0 - d else d;
	}
	#end

	static inline function away(_: Class<Math>, value: Float) return _away(value);
	private static function _away(value: Float): Int {
		final d = Math.ceil(Math.abs(value));
		return if(value < 0) 0 - d else d;
	}

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
		return js.Syntax.code("+({0})", bool);
		#else
		return bool ? 1 : 0;
		#end
	}

	// taken from https://blog.codefrau.net/2014/08/deconstructing-floats-frexp-and-ldexp.html
	static inline function ldexp(_: Class<Math>, x: Float, exp: Int) return _ldexp(x, exp);
	private static function _ldexp(x: Float, exp: Int): Float {
		final steps = min(3, Math.ceil(Math.abs(exp) / 1023));
		var result = x;
		for(i in 0...steps) {
			result *= Math.pow(2, Math.floor((exp + i) / steps));
		}
		return result;
	}

	// taken from https://locutus.io/c/math/frexp/
	static inline function frexp(_: Class<Math>, arg: Float) return _frexp(arg);
	private static function _frexp(arg: Float): Tuple2<Float, Int> {
		if(arg != 0 && Math.isFinite(arg)) {
			final absArg = Math.abs(arg);
			var exp = max(-1023, Math.floor(Math.log2(absArg)) + 1);
			var x = absArg * Math.pow(2, -exp);
			while(x < 0.5) {
				x *= 2;
				exp--;
			}
			while(x >= 1) {
				x *= 0.5;
				exp++;
			}
			if(arg < 0) {
				x = -x;
			}
			return new Tuple2(x, exp);
		} else {
			return new Tuple2(arg, 0);
		}
	}

	// taken from https://gist.github.com/jtmcdole/297434f327077dbfe5fb19da3b4ef5be
	static final ctzLut32 = #if js js.lib.Int8Array.of(
		32, 0, 1, 26, 2, 23, 27, 0,
		3, 16, 24, 30, 28, 11, 0, 13,
		4, 7, 17, 0, 25, 22, 31, 15,
		29, 10, 12, 6, 0, 21, 14, 9,
		5, 20, 8, 19, 18
	) #else null #end;
	static inline function ctz32(_: Class<Math>, x: Int) return _ctz32(x);
	private static function _ctz32(x: Int) return ctzLut32[(x & -x) % 37];
	static inline function ctz64(_: Class<Math>, x: BigInt) return _ctz64(x);
	private static function _ctz64(x: BigInt) {
		var c = 0;
		while(x & bigInt(1) != 1) {
			x >>= bigInt(1);
			c++;
		}
		//trace(x == 0 ? 0 : x.toString(2).split("1").last().length);
		return c;
	}

	static inline function clz64(_: Class<Math>, x: BigInt) return _clz64(x);
	private static function _clz64(x: BigInt) {
		#if js
		//trace(x.toString(2));
		final high = (x >> bigInt(64)).toInt()|0;
		//trace(high.toString(2));
		final res = high == 0 ? 32 : js.lib.Math.clz32(high);
		//trace(res);
		final low = x.toInt()|0;
		//trace(low.toString(2));
		//trace(x, res, res + js.lib.Math.clz32(low));
		if(res == 32) return res + js.lib.Math.clz32(low);
		else return res;
		#else return 0; #end
	}
}