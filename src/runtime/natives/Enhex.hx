package runtime.natives;

import types.base._String;

@:build(runtime.NativeBuilder.build())
class Enhex {
	public static function call(value: _String) {
		return types.String.fromString(Util.encodeURIComponent(value.toJs()));
	}
}