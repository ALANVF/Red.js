package runtime.natives;

import types.base.Context;
import types.base._Block;
import types.base.Options;
import types.base._NativeOptions;
import types.base.Symbol;
import types.*;
import types.TypeKind;

@:build(runtime.NativeBuilder.build())
class Bind {
	public static final defaultOptions = Options.defaultFor(NBindOptions);
	
	static final copyTypeset = new Typeset([
		Runtime.DATATYPES[cast DBlock]._2,
		Runtime.DATATYPES[cast DParen]._2,
		Runtime.DATATYPES[cast DHash]._2
	]);

	static function bindWords(block: _Block, ctx: Context) {
		for(i in 0...block.absLength) block.values[i]._match(
			at(sym is Symbol) => block.values[i] = sym.boundToContext(ctx),
			at(blk is _Block) => bindWords(blk, ctx),
			_ => {}
		);
	}

	public static function call(word: Value, context: Value, options: NBindOptions): Value {
		final ctx = context._match(
			at(sym is Symbol) => sym.context,
			at(obj is Object) => obj.ctx,
			at(ctx_ is Context) => ctx_,
			at(func is Function) => func.ctx,
			_ => throw "error!"
		);

		word._match(
			at(w is Symbol) => return w.boundToContext(ctx),
			at(b is Block) => {
				if(options.copy) {
					b = cast runtime.actions.Copy.call(b, {
						deep: true,
						types: {kind: copyTypeset}
					});
				}

				bindWords(b, ctx);

				return b;
			},
			_ => throw "error!"
		);
	}
}