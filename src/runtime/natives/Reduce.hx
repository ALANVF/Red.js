package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.Value;
import types.Block;
import Util.detuple;

@:build(runtime.NativeBuilder.build())
class Reduce {
	public static final defaultOptions = Options.defaultFor(NReduceOptions);
	
	public static function call(value: Value, options: NReduceOptions): Value {
		options._match(
			at({into: _!}) => throw "NYI!",
			_ => {}
		);

		return value._match(
			at(block is Block) => {
				final values = [];
				final tokens: Series<Value> = block;
				
				while(tokens.isNotTail()) {
					detuple([@var g, tokens], Do.groupNextExpr(tokens));
					values.push(Do.evalGroupedExpr(g));
				}

				new Block(values);
			},
			_ => Do.evalValue(value)
		);
	}
}