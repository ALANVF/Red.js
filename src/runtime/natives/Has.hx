package runtime.natives;

import types.Function;
import types.Block;

@:build(runtime.NativeBuilder.build())
class Has {
	public static function call(locals: Block, body: Block): Function {
		locals = locals.copy();
		locals.values.unshift(new types.Refinement(runtime.Words.LOCAL));
		return Func.call(locals, body);
	}
}