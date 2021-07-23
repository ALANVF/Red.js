package types;

import types.base._Float;

class Float extends _Float {
	function make(value: StdTypes.Float): Float {
		return new Float(value);
	}
}