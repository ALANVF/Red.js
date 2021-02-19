package types;

import types.base._String;

class Tag extends _String {
	public static function fromString(str: std.String) {
		return new Tag(_String.charsFromRed(str));
	}

	function clone(values: Array<Char>, ?index: Int) {
		return new Tag(values, index);
	}
}