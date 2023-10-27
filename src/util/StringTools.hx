package util;

#if js
import js.lib.RegExp;
import haxe.extern.EitherType;

//typedef ReplaceFn = (match: String, ...matches: String/*, index: Int, whole: String, groups: Array<String>*/) -> String;
typedef ReplaceFn = EitherType<
	(match: String) -> String,
	EitherType<
		(match: String, p1: String) -> String,
		EitherType<
			(match: String, p1: String, p2: String) -> String,
			// ... and so on
			(match: String, p1: String, p2: String, p3: String) -> String
		>
	>
>;
#end

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

	static overload extern inline function startsWith(self: String, str: String): Bool
		return #if js js.Syntax.code("{0}.startsWith({1})", self, str) #else null #end;
	static overload extern inline function startsWith(self: String, str: String, position: Int): Bool
		return #if js js.Syntax.code("{0}.startsWith({1}, {2})", self, str, position) #else null #end;

	static overload extern inline function endsWith(self: String, str: String): Bool
		return #if js js.Syntax.code("{0}.endsWith({1})", self, str) #else null #end;
	static overload extern inline function endsWith(self: String, str: String, position: Int): Bool
		return #if js js.Syntax.code("{0}.endsWith({1}, {2})", self, str, position) #else null #end;

	static #if js inline #end function repeat(self: String, times: Int): String {
		#if js
		return js.Syntax.code("{0}.repeat({1})", self, times);
		#else
		var result = self;
		for(_ in 1...times) result += self;
		return result;
		#end
	}

	#if js
	static inline function match(self: String, rx: RegExp): Null<RegExpMatch> {
		return (untyped self).match(rx);
	}

	static inline function matchAll(self: String, rx: RegExp): Array<RegExpMatch> {
		return (untyped self).matchAll(rx);
	}
	
	static overload extern inline function replace(self: String, rx: RegExp, with: ReplaceFn): String
		return (untyped self).replace(rx, with);
	static overload extern inline function replace(self: String, rx: RegExp, with: String): String
		return (untyped self).replace(rx, with);
	
	static overload extern inline function replaceAll(self: String, rx: RegExp, with: ReplaceFn): String
		return (untyped self).replaceAll(rx, with);
	static overload extern inline function replaceAll(self: String, rx: RegExp, with: String): String
		return (untyped self).replaceAll(rx, with);
	
	static overload extern inline function _substr(self: String, start: Int): String
		return (untyped self).substr(start);
	static overload extern inline function _substr(self: String, start: Int, len: Null<Int>): String
		return (untyped self).substr(start, len);
	#else
	static inline function match(self: String, rx: Dynamic): Dynamic return null;
	static inline function matchAll(self: String, rx: Dynamic): Dynamic return null;
	static inline function replace(self: String, rx: Dynamic, with: Dynamic): Dynamic return null;
	static inline function replaceAll(self: String, rx: Dynamic, with: Dynamic): Dynamic return null;

	static inline function _substr(self: String, start: Int, ?len: Int) return self.substr(start, len);
	#end
}