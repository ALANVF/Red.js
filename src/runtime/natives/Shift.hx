package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.Integer;

@:build(runtime.NativeBuilder.build())
class Shift {
	public static final defaultOptions = Options.defaultFor(NShiftOptions);

	public static function call(data: Integer, bits: Integer, options: NShiftOptions) {
		return new Integer(
			if(options.left) (
				data.int << bits.int
			) else if(options.logical) (
				data.int >>> bits.int
			) else (
				data.int >> bits.int
			)
		);
	}
}