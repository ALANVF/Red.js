package runtime.natives;

import types.base.Context;
import types.base.IFunction;
import types.base._Word;
import types.base.Options;
import types.base._NativeOptions;
import types.*;

@:build(runtime.NativeBuilder.build())
class Apply {
	public static final defaultOptions = Options.defaultFor(NApplyOptions);

	public static function call(func: Value, args: Block, options: NApplyOptions) {
		var path: Path = null;
		var fun: IFunction = null;
		var name: Word = null;
		
		func._match(
			at(wp is Path | wp is _Word) => {
				wp._match(
					at(p is Path) => {
						path = p;
						name = cast(path.rawFastPick(0), Word);
					},
					at(w is _Word) => {
						name = cast w;
					},
					_ => throw "bad"
				);
				name.get()._match(
					at(value is IFunction) => {
						fun = value;
					},
					_ => throw "bad"
				);
			},
			at(f is IFunction) => {
				fun = f;
			},
			_ => throw "bad"
		);
		
		return Do.evalGroupedExpr(Do.groupFnApply(fun, path?.skip(1), args, options.all, options.safer)._1);
	}
}