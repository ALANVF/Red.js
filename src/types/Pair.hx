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
		return Util._match(access,
			at((_.symbol.equalsString("x", ignoreCase) => true) is Word) => Some(new Integer(x)),
			at((_.symbol.equalsString("y", ignoreCase) => true) is Word) => Some(new Integer(y)),
			_ => None
		);
	}
}