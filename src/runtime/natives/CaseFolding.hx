package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.base._String;
import types.base._Number;
import types.*;

// TODO: use `haxe-strings` haxelib for case mapping

inline function toChar(str: std.String) {
	// should we be using charPointAt instead?
	return (js.Syntax.code("{0}.charCodeAt(0)", str) : Int);
}

function charToUpper(char: Char) {
	final code = char.int;
	return if(code < 127) {
		char.toUpperCase();
	} else {
		Char.fromCode(toChar(std.String.fromCharCode(code).toUpperCase()));
	}
}

function charToLower(char: Char) {
	final code = char.int;
	return if(code < 127) {
		char.toLowerCase();
	} else {
		Char.fromCode(toChar(std.String.fromCharCode(code).toLowerCase()));
	}
}

function changeCharCase(char: Char, isUpper: Bool) {
	return if(isUpper) {
		inline charToUpper(char);
	} else {
		inline charToLower(char);
	}
}

function changeStringCase(str: _String, isUpper: Bool, length: Int) {
	Util.deepIf({
		for(i in 0...length) {
			final char = str.fastPick(i);
			str.fastPoke(i, @if (isUpper ? charToUpper(char) : charToLower(char)));
		}
	});
}

function changeCase(value: Value, isUpper: Bool, ?limit: Value): Value {
	value._match(
		at(char is Char) => {
			return changeCharCase(char, isUpper);
		},
		at(str is _String) => {
			final length = limit._andOr(l => {
				l._match(
					at(num is _Number) => {
						final len = num.asInt();
						Math.clamp(0, len, str.length);
					},
					at(str2 is _String) => {
						if(str.sameSeriesAs(str2)) {
							if(str2.index < str.index)
								0
							else
								str2.index - str.index;
						} else {
							throw "error!";
						}
					},
					_ => throw "error!"
				);
			}, {
				str.length;
			});

			changeStringCase(str, isUpper, length);
			return str;
		},
		_ => throw "error!"
	);
}

final defaultOptions = Options.defaultFor(NChangeCaseOptions);

@:build(runtime.NativeBuilder.build())
class Uppercase {
	public static function call(value: Value, options: NChangeCaseOptions) {
		return changeCase(value, true, options.part._and(p => p.limit));
	}
}

@:build(runtime.NativeBuilder.build())
class Lowercase {
	public static function call(value: Value, options: NChangeCaseOptions) {
		return changeCase(value, false, options.part._and(p => p.limit));
	}
}