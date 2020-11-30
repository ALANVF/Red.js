package util;

class StringTools {
	public static function fromCharCodes(c: Class<String>, chars: Array<Int>) {
		#if js
			return js.Syntax.code("String.fromCharCode(...{0})", chars);
		#else
			final bytes = haxe.io.Bytes.alloc(chars.length);
			for(i => char in chars) bytes.set(i, char);
			return bytes.toString();
		#end
	}
}