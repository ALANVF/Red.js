package types.base;

using StringTools;
using util.NullTools;

abstract class _String extends _SeriesOf<Char> {
	public static function charsFromRed(str: std.String) {
		return [while(str.length > 0) {
			var code = 0, len = 0;
			if(str.charCodeAt(0) == "^".code) {
				switch(str.charCodeAt(1).notNull()) {
					case c = "\"".code | "^".code: code = c; len = 2;
					case "\\".code: code = 28; len = 2;
					case "]".code:  code = 29; len = 2;
					case "_".code:  code = 31; len = 2;

					case "@".code: code = 0; len = 2;
					case "-".code: code = 9; len = 2;
					case "/".code: code = 10; len = 2;
					case "[".code: code = 27; len = 2;
					case "~".code: code = 127; len = 2;

					case "(".code:
						final nstr = str.substr(2).toUpperCase();
						final mappings = [
							"NULL)" => 0,
							"BACK)" => 8,
							"TAB)" => 9,
							"LINE)" => 10,
							"PAGE)" => 12,
							"ESC)" => 27,
							"DEL)" => 127
						];
						
						var res = null;
						
						for(k => v in mappings) {
							if(nstr.startsWith(k)) {
								res = code = v; len = 2 + k.length;
								break;
							}
						}

						if(res != null) {
							res;
						} else {
							final rx = ~/^([A-F\d]+)\)/i;
							if(rx.match(nstr)) {
								code = Util.mustParseInt("0x" + rx.matched(0)); len = 2 + rx.matchedPos().len;
							} else {
								throw 'Invalid string! escape "^${str.charAt(1)}"!';
							}
						}

					case esc:
						if("A".code <= esc && esc <= "Z".code) {
							code = esc - 64; len = 2;
						} else if("a".code <= esc && esc <= "z".code) {
							code = esc - 32 - 64; len = 2;
						} else {
							throw 'Invalid string! escape "^${str.charAt(1)}"!';
						}
				}
			} else {
				code = str.charCodeAt(0); len = 1;
			};

			str = str.substr(len);
			Char.fromCode(code);
		}];
	}
}