package types;

import types.base._String;

class Url extends _String {
	public static function fromString(str: std.String) {
		return new Url(_String.charsFromRed(str));
	}

	override function clone(values: Array<Char>, ?index: Int) {
		return new Url(values, index);
	}
}