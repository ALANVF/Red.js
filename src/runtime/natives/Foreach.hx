package runtime.natives;

import types.Error;
import types.Word;
import types.Block;
import types.Value;
import types.Map;
import types.base.ISeriesOf;
import haxe.ds.Option;

@:build(runtime.NativeBuilder.build())
class Foreach {
	public static function call(word: Value, series: Value, body: Block) {
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

		switch [words, series] {
			case [[key, value], _.is(Map) => Some(map)]:
				for(i in 0...map.size) {
					key.setValue(map.keys[i]);
					value.setValue(map.values[i]);

					try {
						Do.evalValues(body).isTruthy();
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

			case [[word], _.is(ISeriesOf) => Some((untyped _ : ISeriesOf<Value>) => series)]:
				for(value in series) {
					word.setValue(value);

					try {
						Do.evalValues(body).isTruthy();
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
			
			case [_, _.is(ISeriesOf) => Some((untyped _ : ISeriesOf<Value>) => series)] if(words.length > 0):
				while(!series.isTail()) {
					for(word in words) {
						word.setValue(series.pick(0).orElse(types.None.NONE));
						series = series.skip(1);
					}

					try {
						Do.evalValues(body);
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

			case [_, _]: throw "error!";
		}

		return types.None.NONE;
	}
}