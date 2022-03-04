package runtime.natives;

import types.base._String;

@:build(runtime.NativeBuilder.build())
class Dehex {
	public static function call(value: _String) {
		return types.String.fromString(Util.decodeURIComponent(value.toJs()));
	}
}