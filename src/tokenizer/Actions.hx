package tokenizer;

import tokenizer.DateMatch;

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

	public static function specialFloat(rdr: Reader) {
		var match;
		return if((match = rdr.tryMatchRx(Regexps.nanFloat)) != null) {
			Math.NaN;
		} else if((match = rdr.tryMatchRx(Regexps.infFloat)) != null) {
			if(match[1] == "-") Math.NEGATIVE_INFINITY else Math.POSITIVE_INFINITY;
		} else {
			null;
		}
	}

	public static function number(rdr: Reader) {
		var match;
		return if((match = rdr.tryMatchRx(Regexps.integer)) != null) {
			Util.mustParseInt(match[0]);
		} else if((match = rdr.tryMatchRx(Regexps.float)) != null) {
			Std.parseFloat(match[0]);
		} else {
			specialFloat(rdr);
		}
	}
	
	public static function point(rdr: Reader) {
		final x = number(rdr) ?? throw "Invalid float literal!";
		rdr.matchRx(Regexps.pointComma);
		final y = number(rdr) ?? throw "Invalid float literal!";
		if(rdr.tryMatchRx(Regexps.pointComma) != null) {
			final z = number(rdr) ?? throw "Invalid float literal!";
			rdr.trimSpace();
			rdr.match(")");
			return Token.TPoint3D(x, y, z);
		} else {
			rdr.trimSpace();
			rdr.match(")");
			return Token.TPoint2D(x, y);
		}
	}

	public static function word(rdr: Reader, word: String) {
		return if(rdr.tryMatch(":")) {
			Token.TSetWord(word);
		} else if(rdr.peek() == "/") {
			final path = Actions.path(rdr, Token.TWord(word));
			if(rdr.tryMatch(":")) {
				Token.TSetPath(path);
			} else {
				Token.TPath(path);
			}
		} else if(rdr.tryMatch("@")) {
			var match;
			if((match = @:privateAccess Tokenizer.matchRxWithGuardRx(rdr, RegexpChecks.word, Regexps.word)) != null) {
				Token.TEmail(word + "@" + match[0]);
			} else {
				throw "Invalid email!";
			}
		} else {
			Token.TWord(word);
		}
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
				} else if(rdr.matchesRx(RegexpChecks.specialFloat)) {
					Token.TFloat(specialFloat(rdr));
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

	public static function date(match: DateMatch.Match) {
		var day:   Int,
			month: Int,
			year:  Int;
		
		final date: DateKind = if(DateMatch.isDDMMMY(match)) {
			day = match.date_ddmmmy_dd.asInt();
			
			if(match.date_ddmmmy_mmm_m != null) {
				month = match.date_ddmmmy_mmm_m.asInt();
			} else if(match.date_ddmmmy_mmm_mon != null) {
				month = DateMatch.getMonth(match.date_ddmmmy_mmm_mon) + 1;
			} else if(match.date_ddmmmy_mmm_month != null) {
				month = DateMatch.getMonth(match.date_ddmmmy_mmm_month) + 1;
			} else {
				throw "Error 1!";
			}
			
			if(match.date_ddmmmy_yyyy != null) {
				year = match.date_ddmmmy_yyyy.asInt();
			} else if(match.date_ddmmmy_yy != null) {
				year = match.date_ddmmmy_yy.asInt();
				year += (year > 50) ? 1900 : 2000;
			} else {
				throw "Error 2!";
			}

			YYYYMDD(year, month, day);
		} else if(DateMatch.isYYYYMMMDD(match)) {
			day = match.date_yyyymmmdd_dd.asInt();
			
			if(match.date_yyyymmmdd_mmm_m != null) {
				month = match.date_yyyymmmdd_mmm_m.asInt();
			} else if(match.date_yyyymmmdd_mmm_mon != null) {
				month = DateMatch.getMonth(match.date_yyyymmmdd_mmm_mon) + 1;
			} else if(match.date_yyyymmmdd_mmm_month != null) {
				month = DateMatch.getMonth(match.date_yyyymmmdd_mmm_month) + 1;
			} else {
				throw "Error 3!";
			}
			
			if(match.date_yyyymmmdd_yyyy != null) {
				year = match.date_yyyymmmdd_yyyy.asInt();
			} else {
				throw "Error 4!";
			}
			
			YYYYMDD(year, month, day);
		} else if(DateMatch.isYYYYDDD(match)) {
			YYYYDDD(
				match.date_yyyyddd_yyyy.asInt(),
				match.date_yyyyddd_ddd.asInt()
			);
		} else if(DateMatch.isYYYYW(match)) {
			YYYYWWD(
				match.date_yyyyW_yyyy.asInt(),
				match.date_yyyyW_ww.asInt(),
				match.date_yyyyW_d == null ? 1 : match.date_yyyyW_d.asInt()
			);
		} else if(DateMatch.isDateT(match)) {
			YYYYMDD(
				match.dateT_yyyy.asInt(),
				match.dateT_mm.asInt(),
				match.dateT_dd.asInt()
			);
		} else {
			throw "Error 5!";
		}
		
		final time: Null<TimeKind> = if(match.time != null) {
			if(DateMatch.isHMS(match)) {
				HMS(
					match.time_hms_hour.asInt(),
					match.time_hms_min.asInt(),
					match.time_hms_sec == null ? 0 : match.time_hms_sec.asInt()
				);
			} else if(DateMatch.isHHMM(match)) {
				HHMM(match.time_hhmm.asInt() * 100);
			} else if(DateMatch.isHHMMSS(match)) {
				final ms = (match.time_hhmmss_dec == null) ? 0 : '${match.time_hhmmss_dec}'.asInt();
				HHMMSS(match.time_hhmmss_hhmmss.asInt(), ms);
			} else {
				throw "Error 6!";
			}
		} else null;
		
		final zone: Null<ZoneKind> = if(match.zone != null) {
			if(DateMatch.isZoneHM15(match)) {
				ZoneHM15(
					match.zone_sign,
					match.zone_hm15_hour.asInt(),
					match.zone_hm15_min15.asInt()
				);
			} else if(DateMatch.isZoneHHMM(match)) {
				ZoneHHMM(
					match.zone_sign,
					match.zone_hhmm.asInt()
				);
			} else if(DateMatch.isZoneHour(match)) {
				ZoneHour(
					match.zone_sign,
					match.zone_hour.asInt()
				);
			} else {
				throw "Error 7!";
			}
		} else null;

		return Token.TDate(date, time, zone);
	}

	static function delim(rdr: Reader, name: String, start: String, stop: String) {
		rdr.match(start);

		final out = [];
		
		rdr.trimSpace();

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
		return delim(rdr, "block!", "[", "]");
	}

	public static inline function paren(rdr: Reader) {
		return delim(rdr, "paren!", "(", ")");
	}
	
	public static inline function parenOrPoint(rdr: Reader) {
		if(rdr.matchesRx(RegexpChecks.point)) {
			rdr.match("(");
			rdr.trimSpace();
			return point(rdr);
		} else {
			return Token.TParen(paren(rdr));
		}
	}

	public static inline function map(rdr: Reader) {
		return delim(rdr, "map!", "#[", "]");
	}

	public static inline function construct(rdr: Reader) {
		return delim(rdr, "constructor!", "#(", ")");
	}

	/*public static function date(rdr: Reader) {
		throw "todo!";
	}*/
}
