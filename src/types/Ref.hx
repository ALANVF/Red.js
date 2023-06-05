package types;

import types.base._String;

class Ref extends _String {
	public static function fromString(str: std.String) {
		return new Ref(_String.codesFromRed(str));
	}

	function clone(values: Array<Int>, ?index: Int) {
		return new Ref(values, index);
	}
}