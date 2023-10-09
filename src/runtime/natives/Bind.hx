package runtime.natives;

import types.base.Context;
import types.base._Block;
import types.base.Options;
import types.base._NativeOptions;
import types.base._Word;
import types.base._AnyWord;
import types.*;
import types.TypeKind;

@:build(runtime.NativeBuilder.build())
class Bind {
	public static final defaultOptions = Options.defaultFor(NBindOptions);
	
	static final copyTypeset = Typeset.of([
		Runtime.DATATYPES[cast DBlock]._2,
		Runtime.DATATYPES[cast DParen]._2,
		Runtime.DATATYPES[cast DHash]._2
	]);

	static function bindWords(block: _Block, ctx: Context) {
		for(i in 0...block.absLength) block.values[i]._match(
			at(word is _Word) => block.values[i] = word.copyIn(ctx, ctx.addWord(word)), // is this wrong?
			at(blk is _Block) => bindWords(blk, ctx),
			_ => {}
		);
	}

	public static function call(word: Value, context: Value, options: NBindOptions): Value {
		final ctx = context._match(
			at(word is _AnyWord) => word.context,
			at(obj is Object) => obj.ctx,
			at(ctx_ is Context) => ctx_,
			at(func is Function) => func.ctx,
			_ => throw "error!"
		);

		return _call(word, ctx, options);
	}

	public static function _call(word: Value, ctx: Context, options: NBindOptions): Value {
		word._match(
			at(w is _AnyWord) => return w.copyIn(ctx, ctx.addWord(w)),
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