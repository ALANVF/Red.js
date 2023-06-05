package types;

import types.base._String;

class Tag extends _String {
	public static function fromString(str: std.String) {
		return new Tag(_String.codesFromRed(str));
	}

	function clone(values: Array<Int>, ?index: Int) {
		return new Tag(values, index);
	}
}