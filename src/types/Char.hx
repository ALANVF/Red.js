package types;

class Char extends Value {
	// DCE bug here
	static var chars: Dict<Int, Char> = cast [for(c in 0...256) c => new Char(c)];

	public var code: Int;

	function new(code: Int) {
		this.code = code;
	}

	public static inline function fromCode(code: Int): Char {
		return if(chars.has(code)) {
			chars[code];
		} else {
			chars[code] = new Char(code);
		}
	}

	public static function fromRed(str: std.String) {
		return Char.fromCode(
			if(str.charCodeAt(0) == "^".code) {
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
							esc.charCodeAt(0) - 64;
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
				str.charCodeAt(0);
			} else {
				throw 'Invalid char! literal #"$str"!';
			}
		);
	}

	public function toRed() {
		return switch(this.code) {
			case 34:  "^\"";
			case 94:  "^^";
			case 28:  "^\\";
			case 29:  "^]";
			case 31:  "^_";

			case 0:   "^@";
			case 8:   "^(back)";
			case 9:   "^-";
			case 10:  "^/";
			case 12:  "^(page)";
			case 27:  "^[";
			case 127: "^~";

			case 30:  "^(1E)";

			default:
				if(1 <= this.code && this.code <= 26) {
					"^" + std.String.fromCharCode(this.code + 64);
				} else {
					std.String.fromCharCode(this.code);
				}
		}
	}

	public function toUpperCase() {
		return Char.fromCode(
			if("a".code <= this.code && this.code <= 'z'.code) {
				this.code - 32;
			} else {
				this.code;
			}
		);
	}

	public function toLowerCase() {
		return Char.fromCode(
			if("A".code <= this.code && this.code <= 'Z'.code) {
				this.code + 32;
			} else {
				this.code;
			}
		);
	}

	public function equalsChar(other: Char) {
		return (inline this.toUpperCase()).code == (inline other.toUpperCase()).code;
	}
}