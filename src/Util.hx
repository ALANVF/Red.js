#if (php || neko || cpp || macro || java || lua || python || hl)
	import sys.io.File;
#end

import haxe.ds.Option;

using StringTools;

#if !macro
using util.NullTools;
#end

#if macro
import haxe.macro.Expr;
#end

class Util {
	public static function mustParseInt(str: String) {
		//return Std.parseInt(str).notNull();
		switch Std.parseInt(str) {
			case null: throw "Value was null!";
			case int: return (int : Int);
		}
	}

	public static function readFile(path: String): String {
#if (php || neko || cpp || macro || java || lua || python || hl)
		return File.getContent(path);
#elseif js
		try {
			return js.Lib.require("fs").readFileSync(path).toString();
		} catch(e: Dynamic) {
			js.Lib.rethrow();
			return "";
		}
#else
		throw "todo!";
#end
	}

	static function _pretty(value: Any, indent: Int): String {
		final thisLevel = "".lpad("\t", indent);
		final nextLevel = "".lpad("\t", indent + 1);
		
		return if(value is Array) {
			final array = (value : Array<Any>);

			if(array.length == 0) {
				"[]";
			} else {
				var out = new StringBuf();
				
				out.add("[\n");
				
				for(i in 0...array.length) {
					out.add(nextLevel);
					out.add(_pretty(array[i], indent + 1));
					if(i < array.length - 1) {
						out.add(",");
					}
					out.add("\n");
				}

				out.add('$thisLevel]');

				out.toString();
			}
		} else if(Reflect.isEnumValue(value)) {
			final value = (value : EnumValue);
			final name = value.getName();

			switch value.getParameters() {
				case []: name;
				case [param]: '$name(${_pretty(param, indent)})';
				case params: '$name(\n' + params.map(param -> nextLevel + _pretty(param, indent + 1)).join(",\n") + '\n$thisLevel)';
			}
		} else {
			Std.string(value);
		}
	}

	public static function pretty(value: Any): String {
		return _pretty(value, 0);
	}

	public static macro function assert(expr) {
		return macro {
			if(!($expr)) {
				throw 'Assertion failed: ${haxe.macro.ExprTools.toString(expr)}';
			}
		};
	}

	public static macro function match(value, pattern, expr, ?otherwise) {
		return macro {
			switch($value) {
				case $pattern: $expr;
				default: ${otherwise != null ? otherwise : macro $b{[]}};
			}
		};
	}

	public static macro function extract(value, pattern, expr) {
		return macro {
			switch($value) {
				case $pattern: $expr;
				default: throw "Match error!";
			}
		};
	}

#if (!macro && js)
	public static inline function tryCast<T: {}, S: T>(value: T, c: Class<S>): Option<S> {
		return if(@:privateAccess js.Boot.__downcastCheck(value, c)) Some(cast value) else None;
	}
#end
}