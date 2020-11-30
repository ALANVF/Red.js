package types;

import types.base.IFunction;
import types.base._Function;
import haxe.ds.Option;

class Function extends _Function {
	public final body: Block;

	public function new(doc: Option<std.String>, args: _Args, refines: _Refines, retSpec: Option<Block>, body: Block) {
		super(doc, args, refines, retSpec);
		this.body = body;
	}
}