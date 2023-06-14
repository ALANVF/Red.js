package types;

import types.base.Context;
import types.base.IFunction;
import types.base._Function;

class Function extends _Function {
	public final body: Block;
	public var ctx: Context;

	public function new(ctx: Null<Context>, origSpec: Block, doc: Null<std.String>, params: _Params, refines: _Refines, retSpec: Null<Block>, body: Block) {
		super(origSpec, doc, params, refines, retSpec);

		this.ctx = ctx ?? new Context();
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
		
		if(ctx == null) {
			this.ctx.bind(this.body, false);
		}
	}
}