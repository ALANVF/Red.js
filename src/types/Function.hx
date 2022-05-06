package types;

import types.base.Context;
import types.base.IFunction;
import types.base._Function;

class Function extends _Function {
	public final body: Block;
	public var ctx: Context;

	public function new(doc: Null<std.String>, params: _Params, refines: _Refines, retSpec: Null<Block>, body: Block) {
		super(doc, params, refines, retSpec);

		this.ctx = new Context();
		this.ctx.value = this;

		// bind params/refines
		for(param in params) {
			this.ctx.add(param.name, None.NONE);
		}
		for(refine in refines) {
			this.ctx.add(refine.name, Logic.FALSE);
			for(param in params) {
				this.ctx.add(param.name, None.NONE);
			}
		}

		this.body = body;
		
		runtime.natives.Bind.call(
			this.body,
			this,
			runtime.natives.Bind.defaultOptions
		);
	}
}