package types;

import types.base.Context;
import types.base.IFunction;
import types.base._Function;

class Function extends _Function {
	public final body: Block;
	public var ctx: FunctionContext;

	public function new(doc: Null<std.String>, params: _Params, refines: _Refines, retSpec: Null<Block>, body: Block) {
		super(doc, params, refines, retSpec);

		this.ctx = new FunctionContext(this);
		this.body = body;
		
		runtime.natives.Bind.call(
			this.body,
			this.ctx,
			runtime.natives.Bind.defaultOptions
		);
	}
}

@:publicFields
class FunctionContext extends Context {
	public final func: Function;

	override public function new(func: Function) {
		super();
		this.func = func;
		
		for(param in func.params) {
			this.add(param.name, None.NONE);
		}

		for(refine in func.refines) {
			this.add(refine.name, Logic.FALSE);
			for(param in refine.params) {
				this.add(param.name, None.NONE);
			}
		}
	}
}