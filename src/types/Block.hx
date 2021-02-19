package types;

import types.base._Block;
import util.Set;

class Block extends _Block {
	// Required due to an obscure bug (that's probably caused by the build macro)
	public function new(values: Array<Value>, ?index: Int, ?newlines: Set<Int>) super(values, index, newlines);

	function cloneBlock(values: Array<Value>, ?index: Int, ?newlines: Set<Int>) {
		return new Block(values, index, newlines);
	}
}