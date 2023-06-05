package types;

import types.base.IGetPath;
import types.base._String;
import haxe.ds.Option;

class Email extends _String implements IGetPath {
	public static function fromString(str: std.String) {
		return new Email(_String.codesFromRed(str));
	}

	function clone(values: Array<Int>, ?index: Int) {
		return new Email(values, index);
	}

	override public function getPath(access: Value, ?ignoreCase = true): Option<Value> {
		return Util._match(access,
			at((_.symbol.equalsString("user", ignoreCase) => true) is Word) => Some(new String(values.slice(0, values.indexOf("@".code)))),
			at((_.symbol.equalsString("host", ignoreCase) => true) is Word) => Some(new String(values.slice(values.indexOf("@".code) + 1))),
			_ => super.getPath(access)
		);
	}
}