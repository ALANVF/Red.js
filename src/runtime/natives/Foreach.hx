package runtime.natives;

import types.Error;
import types.Word;
import types.Block;
import types.Value;
import types.Map;
import types.base.ISeriesOf;

@:build(runtime.NativeBuilder.build())
class Foreach {
	public static function call(word: Value, series: Value, body: Block) {
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

		Util._match([words, series],
			at([[key, value], map is Map]) => {
				for(i in 0...map.size) {
					key.setValue(map.keys[i]);
					value.setValue(map.values[i]);

					try {
						Do.evalValues(body);
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
			},
			at([[word], series is ISeriesOf<Value>]) => {
				for(value in series) {
					word.setValue(value);

					try {
						Do.evalValues(body);
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
			},
			at([_, series is ISeriesOf<Value>], when(words.length > 0)) => {
				while(!series.isTail()) {
					for(word in words) {
						word.setValue(series.pick(0).orElse(types.None.NONE));
						series = series.skip(1);
					}

					try {
						Do.evalValues(body);
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
			},
			_ => throw "error!"
		);

		return types.None.NONE;
	}
}