package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.*;

@:build(runtime.NativeBuilder.build())
class Try {
	public static final defaultOptions = Options.defaultFor(NTryOptions);

	public static function call(block: Block, options: NTryOptions) {
		if(options.keep) throw "NYI!";

		try {
			return Do.evalValues(block);
		} catch(e: RedError) {
			if(!options.all && e.isSpecial()) {
				throw e;
			}

			return e.error;
		}
	}
}