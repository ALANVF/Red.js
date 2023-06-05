package types;

import types.base._String;

class String extends _String {
	public static function fromRed(str: std.String) {
		return new String(_String.codesFromRed(str));
	}

	public static function fromString(str: std.String) {
		return new String([for(i in 0...str.length) str.cca(i)]);
	}

	function clone(values: Array<Int>, ?index: Int) {
		return new String(values, index);
	}

	public function form(): std.String {
		return std.String.fromCharCodes(values);
	}
}