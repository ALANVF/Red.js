package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.base._Number;

enum abstract TrigType(Int) {
	final TANGENT;
	final COSINE;
	final SINE;
}

function _degreesToRadians(value: Float, type: TrigType) {
	var val = value % 360.0;

	if(val > 180.0 || val < -180.0) {
		final factor = if(val < 0.0) 360.0 else -360.0;
		val += factor;
	}

	if(val > 90.0 || val < -90.0) {
		switch type {
			case TANGENT: {
				final factor = if(val < 0.0) 180.0 else -180.0;
				val += factor;
			}
			case SINE: {
				final factor = if(val < 0.0) -180.0 else 180.0;
				val = factor - val;
			}
			default:
		}
	}

	val = (val * Math.PI) / 180.0;

	return val;
}

inline function degreesToRadians(value: Float, type: TrigType, isRadians: Bool) {
	return if(isRadians) value else _degreesToRadians(value, type);
}

final defaultOptions = Options.defaultFor(NTrigOptions);

@:build(runtime.NativeBuilder.build())
class Sine {
	public static function call(angle: _Number, options: NTrigOptions) {
		final value = degreesToRadians(angle.asFloat(), SINE, options.radians);
		var res = Math.sin(value);

		if(types.Float.DBL_EPSILON > Math.abs(res)) {
			res = 0.0;
		}

		return new types.Float(res);
	}
}

@:build(runtime.NativeBuilder.build())
class Cosine {
	public static function call(angle: _Number, options: NTrigOptions) {
		final value = degreesToRadians(angle.asFloat(), COSINE, options.radians);
		var res = Math.cos(value);

		if(types.Float.DBL_EPSILON > Math.abs(res)) {
			res = 0.0;
		}

		return new types.Float(res);
	}
}

@:build(runtime.NativeBuilder.build())
class Tangent {
	public static function call(angle: _Number, options: NTrigOptions) {
		final value = degreesToRadians(angle.asFloat(), TANGENT, options.radians);
		final res = (
			if(value == Math.PI/2)
				Math.NEGATIVE_INFINITY
			else if(value == Math.PI/-2)
				Math.POSITIVE_INFINITY
			else
				Math.tan(value)
		);

		return new types.Float(res);
	}
}

function arcTrans(value: Float, type: TrigType, isRadians: Bool) {
	final res = switch type {
		case SINE: Math.asin(value);
		case COSINE: Math.acos(value);
		case TANGENT: Math.atan(value);
	};

	return if(isRadians) (
		res
	) else (
		(res * 180.0) / Math.PI
	);
}

@:build(runtime.NativeBuilder.build())
class Arcsine {
	public static function call(angle: _Number, options: NTrigOptions) {
		return new types.Float(arcTrans(angle.asFloat(), SINE, options.radians));
	}
}

@:build(runtime.NativeBuilder.build())
class Arccosine {
	public static function call(angle: _Number, options: NTrigOptions) {
		return new types.Float(arcTrans(angle.asFloat(), COSINE, options.radians));
	}
}

@:build(runtime.NativeBuilder.build())
class Arctangent {
	public static function call(angle: _Number, options: NTrigOptions) {
		return new types.Float(arcTrans(angle.asFloat(), TANGENT, options.radians));
	}
}

@:build(runtime.NativeBuilder.build())
class Arctangent2 {
	public static function call(y: _Number, x: _Number, options: NTrigOptions) {
		final yval = y.asFloat();
		final xval = x.asFloat();
		var res = Math.atan2(yval, xval);

		if(!options.radians) {
			res = (180.0 / Math.PI) * res;
		}

		return new types.Float(res);
	}
}