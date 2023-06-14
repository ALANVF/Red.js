package runtime.natives;

import types.Function;
import types.Block;

@:build(runtime.NativeBuilder.build())
class Does {
	public static function call(body: Block): Function {
		return new Function(null, new Block([]), null, [], [], null, body.copy());
	}
}