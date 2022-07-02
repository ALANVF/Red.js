package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.base._BlockLike;
import types.base._Path;
import types.Value;
import types.Block;
import types.Paren;

@:build(runtime.ActionBuilder.build())
class Copy {
	public static final defaultOptions = Options.defaultFor(ACopyOptions);

	public static function call(value: Value, options: ACopyOptions) {
		return Actions.getFor(value).copy(value, options);
	}

	public static function block<T: _BlockLike>(blk: T, deep: Bool, any: Bool) {
		if(blk.length == 0) {
			return (untyped blk.copy() : T);
		}

		final res = (untyped blk.copy() : T);

		if(deep) {
			final values = blk.values;
			final length = blk.absLength;

			Util.deepIf(
				for(i in 0...length) {
					final value = values[i];
					if(@if (any
						? (value is Block || value is Paren || value is _Path)
						: (value is Block)
					)) {
						values[i] = block((untyped value : _BlockLike), true, @if (any ? true : false));
					}
				}
			);
		}

		return res;
	}
}