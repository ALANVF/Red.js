package runtime.natives;

import types.Error;
import types.Block;
import types.Word;

@:build(runtime.NativeBuilder.build())
class Forall {
	public static function call(word: Word, body: Block) {
		final saved = word.get();
		
		var series = saved.asSeries();
		while(!series.isTail()) {
			try {
				Do.evalValues(body);
			} catch(e: RedError) {
				if(e.isContinue()) {
					continue;
				} else if(e.isBreak()) {
					word.set(saved);
					return e.get("arg1");
				} else {
					word.set(saved);
					throw e;
				}
			}
			
			series = series.skip(1);
			word.set(series);
		}
		
		word.set(saved);
		return types.None.NONE;
	}
}