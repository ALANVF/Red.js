package runtime.natives;

import types.Word;
import types.Error;
import types.Block;
import types.Value;

@:build(runtime.NativeBuilder.build())
class RemoveEach {
	public static function call(word: Value, data: Value, body: Block) {
		final words = word._match(
			at(word is Word) => [word],
			at(block is Block) => {
				if(block.length == 0) {
					throw "block length must not be zero!";
				} else {
					[for(value in block) cast(value, Word)];
				}
			},
			_ => throw "error!"
		);
		var series = data.asISeries();

		switch words {
			case [word]:
				for(value in series) {
					word.set(value);

					try {
						if(Do.evalValues(body).isTruthy()) {
							series.remove();
						}
					} catch(e: RedError) {
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
						word.set(series.pick(count) ?? cast types.None.NONE);
						count++;
					}

					try {
						if(Do.evalValues(body).isTruthy()) {
							series.removePart(count);
						} else {
							series = series.skip(count);
						}
					} catch(e: RedError) {
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