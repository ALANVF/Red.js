package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.base._Block;
import types.Logic;

@:build(runtime.NativeBuilder.build())
class NewLine {
	public static final defaultOptions = Options.defaultFor(NNewLineOptions);

	public static function call(list: _Block, value: Logic, options: NNewLineOptions): _Block {
		final start = list.index;
		final cond = value.cond;

		list.setNewline(start, cond);

		if(options.all || options.skip != null) {
			final end = list.absLength;
			final step = options.skip._andOr(
				opt => opt.size.int,
				1
			);
			
			var i = start + step;
			while(i < end) {
				list.setNewline(i, cond);
				i += step;
			}
		}

		return list;
	}
}