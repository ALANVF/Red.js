package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.Integer;
import types.Issue;

@:build(runtime.NativeBuilder.build())
class ToHex {
	public static final defaultOptions = Options.defaultFor(NToHexOptions);

	public static function call(value: Integer, options: NToHexOptions) {
		final int = value.int;
		final length = options.size._andOr(s => {
			final l = s.length.int;
			if(l < 0) throw "error!";
			l;
		}, 8);
		final hex = (js.Syntax.code("{0}.toString(16).toUpperCase().padStart({1}, '0')", int, length) : String);

		return new Issue(hex);
	}
}