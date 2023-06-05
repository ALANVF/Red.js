package types;

import types.base._String;

class File extends _String {
	public static function fromString(str: std.String) {
		return new File(_String.codesFromRed(str));
	}

	function clone(values: Array<Int>, ?index: Int) {
		return new File(values, index);
	}
}