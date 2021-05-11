package runtime.natives;

import types.Error;
import types.Block;
import types.Word;

@:build(runtime.NativeBuilder.build())
class Forall {
	public static function call(word: Word, body: Block) {
		final saved = word.getValue();
		
		var series = saved.asSeries();
		while(!series.isTail()) {
			try {
				Do.evalValues(body);
			} catch(e: Error) {
				if(e.isContinue()) {
					continue;
				} else if(e.isBreak()) {
					word.setValue(saved);
					return e.get("arg1");
				} else {
					word.setValue(saved);
					throw e;
				}
			}
			
			series = series.skip(1);
			word.setValue(series);
		}
		
		word.setValue(saved);
		return types.None.NONE;
	}
}