package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.*;

@:build(runtime.NativeBuilder.build())
class Case {
	public static final defaultOptions = Options.defaultFor(NCaseOptions);

	public static function call(cases: Block, options: NCaseOptions): Value {
		final all = options.all;
		var res: Value = None.NONE;
		var tokens: Series<Value> = cases;

		Util.deepIf({
			@if(all) var trueAtLeastOnce = false;

			while(tokens.isNotTail()) {
				Util.set([@var cond, tokens], Do.doNextValue(tokens));

				if(cond.isTruthy()) {
					if(tokens.isTail()) {
						return @if (all ? (trueAtLeastOnce ? cond : None.NONE) : None.NONE);
					}
					
					res = tokens[0]._match(
						at(b is Block) => {
							tokens++;
							Do.evalValues(b);
						},
						_ => {
							Util.set([@var value, tokens], Do.doNextValue(tokens));
							value;
						}
					);
					@if(all) if(!trueAtLeastOnce) trueAtLeastOnce = true;
					@unless(all) return res;
				} else {
					if(tokens.isTail()) {
						return @if (all ? res : None.NONE);
					} else {
						tokens++;
					}
				}
			}
		});

		return res;
	}
}