package types;

import types.base._Block;
import util.Set;

class Paren extends _Block {
	override function cloneBlock(values: Array<Value>, ?index: Int, ?newlines: Set<Int>) {
		return new Paren(values, index, newlines);
	}
}