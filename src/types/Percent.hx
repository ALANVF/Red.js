package types;

import types.base._Float;

class Percent extends _Float {
	function make(value: StdTypes.Float): Percent {
		return new Percent(value);
	}
}