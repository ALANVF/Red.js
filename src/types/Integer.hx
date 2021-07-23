package types;

import types.base._Integer;

class Integer extends _Integer {
	function make(value: Int): Integer {
		return new Integer(value);
	}
}