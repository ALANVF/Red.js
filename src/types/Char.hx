package types;

import types.base._Integer;

class Char extends _Integer {
	public static inline final MAX_CODEPOINT: Int = 0x0010FFFF;

	// Optimization bug here
	static var chars: Dict<Int, Char>;
	
	private static macro function genChars() {
		final thing = [for(c in 0...256) macro untyped [$v{c}, new Char($v{c})]];
		return macro $a{thing};
	}

	static function __init__() {
		#if !(macro || display)
		chars = new Dict(genChars());
		#end
	}

	private function new(code: Int) {
		super(code);
	}
	
	function make(value: Int): Char {
		return fromCode(value);
	}

	// maybe don't inline this
	public static /*inline*/ function fromCode(code: Int): Char {
		/*return if(chars.has(code)) {
			chars[code];
		} else {
			chars[code] = new Char(code);
		}*/
		/*#if js
		return js.Syntax.code("{0}.get({1}) ?? (tmp = {0}.set({1}, new {2}({1})), tmp)", chars, code, Char);
		#else
		return null;
		#end*/
		return chars[code] ?? (chars[code] = new Char(code));
	}

	public static function fromRed(str: std.String) {
		return Char.fromCode(
			if(str.cca(0) == "^".code) {
				switch(str.substr(1).toUpperCase()) {
					case "\"": 34;
					case "^":  94;
					case "\\": 28;
					case "]":  29;
					case "_":  31;

					case "@" | "(NULL)": 0;
					case "(BACK)":       8;
					case "-" | "(TAB)":  9;
					case "/" | "(LINE)": 10;
					case "(PAGE)":       12;
					case "[" | "(ESC)":  27;
					case "~" | "(DEL)":  127;

					case esc:
						if(esc.length == 1 && "A" <= esc && esc <= "Z") {
							esc.cca(0) - 64;
						} else {
							final rx = ~/^\(([A-F\d]+)\)$/i;
							if(rx.match(esc)) {
								Util.mustParseInt("0x" + rx.matched(0));
							} else {
								throw 'Invalid char! literal #"^$esc"!';
							}
						}
				}
			} else if(str.length == 1) {
				str.cca(0);
			} else {
				throw 'Invalid char! literal #"$str"!';
			}
		);
	}

	public function toRed() {
		return Util._match(this.int,
			at(34)  => "^\"",
			at(94)  => "^^",
			at(28)  => "^\\",
			at(29)  => "^]",
			at(31)  => "^_",

			at(0)   => "^@",
			at(8)   => "^(back)",
			at(9)   => "^-",
			at(10)  => "^/",
			at(12)  => "^(page)",
			at(27)  => "^[",
			at(127) => "^~",

			at(30)  => "^(1E)",

			at((1 ... 7) | 11 | (13 ... 26)) => "^" + std.String.fromCharCode(this.int + 64),

			_ => std.String.fromCharCode(this.int)
		);
	}

	public function toUpperCase() {
		return if("a".code <= this.int && this.int <= 'z'.code) {
			Char.fromCode(this.int - 32);
		} else {
			this;
		}
	}

	public function toLowerCase() {
		return if("A".code <= this.int && this.int <= 'Z'.code) {
			Char.fromCode(this.int + 32);
		} else {
			this;
		}
	}

	public function equalsChar(other: Char) {
		return (inline this.toUpperCase()).int == (inline other.toUpperCase()).int;
	}
}