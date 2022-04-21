package runtime;

import types.Error;
import types.Word;

@:publicFields
class RedError extends haxe.Exception {
	final error: Error;
	final name: Null<Word>;

	function new(error: Error, ?name: Word, ?previous: haxe.Exception, ?native: Any) {
		super(error.description(), previous, native);
		this.error = error;
		this.name = name;
	}

	inline function isContinue() return error.isContinue();

	inline function isBreak() return error.isBreak();

	inline function isReturn() return error.isReturn();

	inline function isThrow() return error.isThrow();

	inline function isSpecial() return error.isSpecial();

	inline function get(name: String, ignoreCase = true) return error.get(name, ignoreCase);
}