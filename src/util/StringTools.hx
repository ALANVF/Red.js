package util;

@:publicFields
class StringTools {
	static #if js inline #end function fromCharCodes(c: Class<String>, chars: Array<Int>) {
		#if js
			return js.Syntax.code("String.fromCharCode(...{0})", chars);
		#else
			final bytes = haxe.io.Bytes.alloc(chars.length);
			for(i => char in chars) bytes.set(i, char);
			return bytes.toString();
		#end
	}

	static inline function cca(self: String, index: Int): Null<Int> {
		#if js
		return js.Syntax.code("{0}.charCodeAt({1})", self, index);
		#else
		return self.charCodeAt(index);
		#end
	}

	static overload extern inline function padStart(self: String, length: Int): String
		return #if js js.Syntax.code("{0}.padStart({1})", self, length) #else null #end;
	static overload extern inline function padStart(self: String, length: Int, padString: String): String
		return #if js js.Syntax.code("{0}.padStart({1}, {2})", self, length, padString) #else null #end;

	static overload extern inline function padEnd(self: String, length: Int): String
		return #if js js.Syntax.code("{0}.padEnd({1})", self, length) #else null #end;
	static overload extern inline function padEnd(self: String, length: Int, padString: String): String
		return #if js js.Syntax.code("{0}.padEnd({1}, {2})", self, length, padString) #else null #end;

	static inline function includes(self: String, needle: String): Bool
		return #if js js.Syntax.code("{0}.includes({1})", self, needle) #else false #end;
}