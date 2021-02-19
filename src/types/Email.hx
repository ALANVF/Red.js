package types;

import types.base.IGetPath;
import types.base._String;
import haxe.ds.Option;

using util.ArrayTools;

class Email extends _String implements IGetPath {
	public static function fromString(str: std.String) {
		return new Email(_String.charsFromRed(str));
	}

	function clone(values: Array<Char>, ?index: Int) {
		return new Email(values, index);
	}

	override public function getPath(access: Value, ?ignoreCase = true): Option<Value> {
		return switch access.KIND {
			case KWord(_.equalsString("user", ignoreCase) => true): Some(new String(values.slice(0, values.findIndex(c -> c.code == "@".code))));
			case KWord(_.equalsString("host", ignoreCase) => true): Some(new String(values.slice(values.findIndex(c -> c.code == "@".code) + 1)));
			default: super.getPath(access);
		};
	}
}