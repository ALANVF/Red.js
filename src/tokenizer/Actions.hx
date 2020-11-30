package tokenizer;

import Util;

class Actions {
	public static var makeNext: (rdr: Reader) -> Token;

	public static function anyWord(rdr: Reader) {
		if(rdr.matchesRx(Regexps.word)) {
			return rdr.matchRx(Regexps.word)[0];
		} else if(rdr.matchesRx(Regexps.specialWord)) {
			return rdr.matchRx(Regexps.specialWord)[0];
		} else {
			throw 'Error while parsing word! at ${rdr.getLocStr()}';
		}
	}

	public static function integer(rdr: Reader) {
		return Util.mustParseInt(rdr.matchRx(Regexps.integer)[0]);
	}

	public static function float(rdr: Reader) {
		return Std.parseFloat(rdr.matchRx(Regexps.float)[0]);
	}

	public static function path(rdr: Reader, head: Token) {
		final out = [head];
		
		while(rdr.tryMatch("/")) {
			out.push(
				if(rdr.matches(RegexpChecks.paren)) {
					Token.TParen(paren(rdr));
				} else if(Checks.anyWord(rdr)) {
					Token.TWord(anyWord(rdr));
				} else if(rdr.matchesRx(RegexpChecks.integer)) {
					Token.TInteger(integer(rdr));
				} else if(rdr.matchesRx(RegexpChecks.float)) {
					Token.TFloat(float(rdr));
				} else if(rdr.tryMatch("'")) {
					if(Checks.anyWord(rdr)) {
						Token.TWord(anyWord(rdr));
					} else {
						throw 'Error while parsing path! at ${rdr.getLocStr()} (debug: 1)';
					}
				} else if(rdr.tryMatch(":")) {
					if(Checks.anyWord(rdr)) {
						Token.TGetWord(anyWord(rdr));
					} else {
						throw 'Error while parsing path! at ${rdr.getLocStr()} (debug: 2)';
					}
				} else {
					throw 'Error while parsing path! at ${rdr.getLocStr()} (debug: 3)';
				}
			);
		}

		return out;
	}

	static function delim(rdr: Reader, name: String, start: String, stop: String) {
		rdr.match(start);

		final out = [];
		
		while(!rdr.matches(stop)) {
			if(rdr.eof()) {
				throw 'Error while parsing $name at ${rdr.getLocStr()}';
			}

			out.push(makeNext(rdr));
		}
		
		rdr.match(stop);

		return out;
	}

	public static inline function block(rdr: Reader) {
		return delim(rdr, "paren!", "[", "]");
	}
	
	public static inline function paren(rdr: Reader) {
		return delim(rdr, "block!", "(", ")");
	}

	public static inline function map(rdr: Reader) {
		return delim(rdr, "map!", "#(", ")");
	}

	public static inline function construct(rdr: Reader) {
		return delim(rdr, "constructor!", "#[", "]");
	}

	/*public static function date(rdr: Reader) {
		throw "todo!";
	}*/
}
