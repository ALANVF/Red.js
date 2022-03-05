package runtime.natives;

import types.base._Number;

@:build(runtime.NativeBuilder.build("LOG_2"))
class Log2 {
	public static function call(value: _Number) {
		return new types.Float(js.lib.Math.log2(value.asFloat()));
	}
}

@:build(runtime.NativeBuilder.build("LOG_10"))
class Log10 {
	public static function call(value: _Number) {
		return new types.Float(js.lib.Math.log10(value.asFloat()));
	}
}

@:build(runtime.NativeBuilder.build())
class LogE {
	public static function call(value: _Number) {
		return new types.Float(js.lib.Math.log(value.asFloat()));
	}
}

@:build(runtime.NativeBuilder.build())
class Exp {
	public static function call(value: _Number) {
		return new types.Float(js.lib.Math.exp(value.asFloat()));
	}
}

@:build(runtime.NativeBuilder.build())
class SquareRoot {
	public static function call(value: _Number) {
		return new types.Float(js.lib.Math.sqrt(value.asFloat()));
	}
}