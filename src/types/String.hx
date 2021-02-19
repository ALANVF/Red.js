package types;

import types.base._String;

using util.StringTools;

class String extends _String {
	public static function fromRed(str: std.String) {
		return new String(_String.charsFromRed(str));
	}

	public static function fromString(str: std.String) {
		return new String([for(i in 0...str.length) Char.fromCode(str.charCodeAt(i))]);
	}

	function clone(values: Array<Char>, ?index: Int) {
		return new String(values, index);
	}

	public function form() {
		return std.String.fromCharCodes([for(c in values) c.code]);
	}
}