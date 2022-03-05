package types;

import types.base._Float;

class Float extends _Float {
	public static final DBL_EPSILON = 2.2204460492503131e-16;

	function make(value: StdTypes.Float): Float {
		return new Float(value);
	}
}