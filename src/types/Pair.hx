package types;

import types.base.IGetPath;
import haxe.ds.Option;

class Pair extends Value implements IGetPath {
	public var x: Int;
	public var y: Int;

	public function new(x: Int, y: Int) {
		this.x = x;
		this.y = y;
	}

	public function getPath(access: Value, ?ignoreCase = true): Option<Value> {
		return switch access.KIND {
			case KWord(_.equalsString("x", ignoreCase) => true): Some(new Integer(x));
			case KWord(_.equalsString("y", ignoreCase) => true): Some(new Integer(y));
			default: None;
		};
	}
}