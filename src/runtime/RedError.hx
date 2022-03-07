package runtime;

import types.Error;

@:publicFields
class RedError extends haxe.Exception {
	final error: Error;

	function new(error: Error, ?previous: haxe.Exception, ?native: Any) {
		super(error.description(), previous, native);
		this.error = error;
	}

	inline function isContinue() return error.isContinue();

	inline function isBreak() return error.isBreak();

	inline function isReturn() return error.isReturn();

	inline function isThrow() return error.isThrow();

	inline function isSpecial() return error.isSpecial();

	inline function get(name: String, ignoreCase = true) return error.get(name, ignoreCase);
}