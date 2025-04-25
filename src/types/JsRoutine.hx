package types;

import haxe.extern.EitherType;
import types.base.IFunction;
import types.base._Function;

typedef _Refs = Dynamic<EitherType<Bool, Null<Array<Value>>>>;
typedef _Routine = (args: Array<Value>, refs: _Refs) -> Null<Value>;

class JsRoutine extends _Function {
	public final fn: _Routine;

	public function new(origSpec: Block, doc: Null<std.String>, params: _Params, refines: _Refines, retSpec: Null<Block>, fn: _Routine) {
		super(origSpec, doc, params, refines, retSpec);
		this.fn = fn;
	}
}