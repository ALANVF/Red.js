package types;

import types.base._String;

class Ref extends _String {
	public static function fromString(str: std.String) {
		return new Ref(_String.charsFromRed(str));
	}

	override function clone(values: Array<Char>, ?index: Int) {
		return new Ref(values, index);
	}
}