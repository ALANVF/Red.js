package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.Value;
import types.Block;
import haxe.ds.Option;

@:build(runtime.NativeBuilder.build())
class Reduce {
	public static final defaultOptions = Options.defaultFor(NReduceOptions);
	
	public static function call(value: Value, options: NReduceOptions): Value {
		final result = switch value {
			case _.is(Block) => Some(block):
				final values = [];
				final tokens = [for(v in block) v.KIND];
				
				while(tokens.length != 0) {
					values.push(Do.evalGroupedExpr(Do.groupNextExpr(tokens)));
				}

				new Block(values);
			
			default:
				Do.evalValue(value);
		};
		
		switch options {
			case {into: Some(_)}:
				throw "NYI!";
			
			default:
				return result;
		}
	}
}