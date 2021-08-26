package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.*;

@:build(runtime.NativeBuilder.build())
class Case {
	public static final defaultOptions = Options.defaultFor(NCaseOptions);

	public static function call(cases: Block, options: NCaseOptions): Value {
		final len = cases.length;
		final all = options.all;
		var res: Value = None.NONE;

		var i = 0;
		Util.deepIf({
			while(i < len) {
				final r = Do.doNextValue(cases);

				i += r.offset;
				
				if(r.value.isTruthy()) {
					if(i >= len) {
						return @if (all ? r.value : None.NONE);
					} else {
						cases = cases.skip(r.offset);
					}
					
					res = cases.fastPick(0)._match(
						at(b is Block) => {
							i++;
							cases = cases.skip(1);
							Do.evalValues(b);
						},
						_ => {
							final r2 = Do.doNextValue(cases);
							i += r2.offset;
							cases = cases.skip(r2.offset);
							r2.value;
						}
					);
					@unless(all) return res;
				} else {
					if(i >= len) {
						return @if (all ? res : None.NONE);
					} else {
						i++;
						cases = cases.skip(r.offset + 1);
					}
				}
			}
		});

		return res;
	}
}