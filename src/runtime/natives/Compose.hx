package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.Value;
import types.Paren;
import types.Block;
import Util.detuple;

@:build(runtime.NativeBuilder.build())
class Compose {
	public static final defaultOptions = Options.defaultFor(NComposeOptions);
	
	public static function call(block: Block, options: NComposeOptions): Block {
		options._match(
			at({into: _!}) => throw "NYI!",
			_ => {}
		);

		final values = [];
		
		Util.deepIf({
			for(value in block) {
				value._match(
					at(p is Paren) => @if (options.only
						? values.push(Do.evalValues(p))
						: Do.evalValues(p)._match(
							at(b is Block) => for(v in b) values.push(v),
							at(v) => values.push(v)
						)
					),
					at(b is Block, when(options.deep)) => values.push(call(b, options)),
					_ => values.push(value)
				);
			}
		});

		return new Block(values);
	}
}