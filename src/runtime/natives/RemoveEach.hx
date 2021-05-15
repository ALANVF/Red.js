package runtime.natives;

import types.Word;
import types.Error;
import types.Block;
import types.Value;
import haxe.ds.Option;

@:build(runtime.NativeBuilder.build())
class RemoveEach {
	public static function call(word: Value, data: Value, body: Block) {
		final words = switch word {
			case _.is(Word) => Some(word): [word];
			case _.is(Block) => Some(block):
				if(block.length == 0) {
					throw "block length must not be zero!";
				} else {
					[for(value in block) value.as(Word)];
				}
			default: throw "error!";
		};
		var series = data.asISeries();

		switch words {
			case [word]:
				for(value in series) {
					word.setValue(value);

					try {
						if(Do.evalValues(body).isTruthy()) {
							series.remove();
						}
					} catch(e: Error) {
						if(e.isContinue()) {
							continue;
						} else if(e.isBreak()) {
							return e.get("arg1");
						} else {
							throw e;
						}
					}
				}
			
			default:
				while(!series.isTail()) {
					var count = 0;
					for(word in words) {
						word.setValue(series.pick(count).orElse(types.None.NONE));
						count++;
					}

					try {
						if(Do.evalValues(body).isTruthy()) {
							series.removePart(count);
						} else {
							series = series.skip(count);
						}
					} catch(e: Error) {
						if(e.isContinue()) {
							continue;
						} else if(e.isBreak()) {
							return e.get("arg1");
						} else {
							throw e;
						}
					}
				}
		}

		return types.None.NONE;
	}
}