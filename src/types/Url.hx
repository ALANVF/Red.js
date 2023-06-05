package types;

import types.base._String;

class Url extends _String {
	public static function fromString(str: std.String) {
		return new Url(_String.codesFromRed(str));
	}

	function clone(values: Array<Int>, ?index: Int) {
		return new Url(values, index);
	}
}