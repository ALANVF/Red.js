import types.Paren;
import tokenizer.*;
//import tokenizer.Token;

using util.MathTools;

class Tokenizer {
	static function matchRxWithGuardRx(rdr: Reader, guard: EReg, rx: EReg) {
		return if(rdr.matchesRx(guard)) {
			rdr.matchRx(rx);
		} else {
			null;
		}
	}

	static function matchRxWithGuard(rdr: Reader, guard: String, rx: EReg) {
		return if(rdr.matches(guard)) {
			rdr.matchRx(rx);
		} else {
			null;
		}
	}

	static function eatEmpty(rdr: Reader) {
		do rdr.trimSpace() while(rdr.tryMatchRx(Regexps.comment) != null);
	}

	public static function makeNext(rdr: Reader): Token {
		eatEmpty(rdr);
		
		var match: Null<Array<String>> = null;
		final res = if((match = rdr.tryMatchRx(Regexps.div)) != null) {
			Token.TWord(match[0]);
		} else if((match = rdr.tryMatchRx(Regexps.getDiv)) != null) {
			Token.TGetWord(match[1]);
		} else if((match = rdr.tryMatchRx(Regexps.litDiv)) != null) {
			Token.TLitWord(match[1]);
		} else if((match = rdr.tryMatchRx(Regexps.setDiv)) != null) {
			Token.TSetWord(match[1]);
		} else if((match = matchRxWithGuard(rdr, RegexpChecks.ref, Regexps.ref)) != null) {
			Token.TRef(match[1]);
		} else if((match = matchRxWithGuard(rdr, RegexpChecks.refinement, Regexps.refinement)) != null) { // [_, refine]
			Token.TRefinement(match[1]);
		} else if((match = rdr.tryMatchRx(Regexps.hexa)) != null) { // [_, hexa]
			Token.TInteger(Util.mustParseInt('0x${match[1]}'));
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.file, Regexps.file)) != null) { // [_, file]
			Token.TFile(match[1]);
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.url, Regexps.url)) != null) { // [_, url]
			Token.TUrl(match[1]);
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.word, Regexps.word)) != null) { // [word]
			final word = match[0];
			if(rdr.tryMatch(":")) {
				Token.TSetWord(word);
			} else if(rdr.peek() == "/") {
				final path = Actions.path(rdr, Token.TWord(word));
				if(rdr.tryMatch(":")) {
					Token.TSetPath(path);
				} else {
					Token.TPath(path);
				}
			} else {
				Token.TWord(word);
			}
		} else if((match = rdr.tryMatchRx(RegexpChecks.specialWord)) != null) { // [word]
			final word = match[0];
			if(rdr.tryMatch(":")) {
				Token.TSetWord(word);
			} else {
				Token.TWord(word);
			}
		} else if(rdr.tryMatch(":")) {
			switch rdr {
				case matchRxWithGuardRx(_, RegexpChecks.word, Regexps.word) => [word]:
					if(rdr.peek() == ":") {
						throw "error!";
					} else if(rdr.peek() == "/") {
						final path = Actions.path(rdr, TWord(word));
						if(rdr.peek() == ":") {
							throw "error!";
						} else {
							Token.TGetPath(path);
						}
					} else {
						Token.TGetWord(word);
					}
				case _.tryMatchRx(RegexpChecks.specialWord) => [word]:
					if(rdr.peek() == ":") {
						throw "error!";
					} else {
						Token.TGetWord(word);
					}
				default: throw "error!";
			}
		} else if(rdr.tryMatch("'")) {
			switch rdr {
				case matchRxWithGuardRx(_, RegexpChecks.word, Regexps.word) => [word]:
					if(rdr.peek() == ":") {
						throw "error!";
					} else if(rdr.peek() == "/") {
						final path = Actions.path(rdr, TWord(word));
						if(rdr.peek() == ":") {
							throw "error!";
						} else {
							Token.TLitPath(path);
						}
					} else {
						Token.TLitWord(word);
					}
				case _.tryMatchRx(RegexpChecks.specialWord) => [word]:
					if(rdr.peek() == ":") {
						throw "error!";
					} else {
						Token.TLitWord(word);
					}
				default: throw "error!";
			}
			
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.issue, Regexps.issue)) != null) { // [_, issue]
			Token.TIssue(match[1]);
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.pair, Regexps.pair)) != null) { // [_, x, y]
			Token.TPair(Util.mustParseInt(match[1]), Util.mustParseInt(match[2]));
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.time, Regexps.time)) != null) { // [_, h, m, s]
			final s = match[3];
			Token.TTime(Util.mustParseInt(match[1]), Util.mustParseInt(match[2]), if(s == null) 0 else Std.parseFloat(s));
		} else if(rdr.matchesRx(RegexpChecks.date)) {
			throw "todo!";
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.float, Regexps.float)) != null) { // [Std.parseFloat(_) => float]
			final float = Std.parseFloat(match[0]);
			if(rdr.tryMatch("%")) {
				Token.TPercent(float);
			} else {
				Token.TFloat(float);
			}
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.integer, Regexps.integer)) != null) { // [Util.mustParseInt(_) => integer]
			final integer = Util.mustParseInt(match[0]);
			if(rdr.tryMatch("%")) {
				Token.TPercent(integer);
			} else {
				Token.TInteger(integer);
			}
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.tuple, Regexps.tuple)) != null) { // match if(match != null)
			final end = match.indexOf(js.Lib.undefined);
			Token.TTuple(match.slice(1, end == -1 ? null : end).map(Util.mustParseInt));
		} else if((match = matchRxWithGuard(rdr, RegexpChecks.char, Regexps.char)) != null) { // [_, char]
			Token.TChar(match[1]);
		} else if((match = matchRxWithGuard(rdr, RegexpChecks.string, Regexps.string)) != null) { // [_, string]
			Token.TString(match[1]);
		} else if(rdr.tryMatch(RegexpChecks.multiString)) {
			final out = new StringBuf();
			var level = 1;

			while(level > 0) {
				if(rdr.eof()) {
					throw 'Syntax error: Invalid string! near "$out"  at ${rdr.getLocStr()}';
				}

				switch rdr.next() {
					case "{":
						out.add("{");
						level++;
					case "}" if(level > 0):
						out.add("}");
						level--;
					case "}":
						break;
					case "^":
						out.add(switch rdr.next() {
							case c = "{" | "}": c;
							case c: '^$c';
						});
					case c:
						out.add(c);
				}
			}

			Token.TString(out.toString());
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.tag, Regexps.tag)) != null) { // [_, tag]
			Token.TTag(match[1]);
		} else if(rdr.tryMatch("2#{")) {
			final out = new StringBuf();

				eatEmpty(rdr);

				while(!rdr.tryMatch("}")) {
					for(_ in 0...8) {
						switch rdr.next() {
							case c = "0" | "1": out.add(c);
							case c: throw 'Unexpected character "$c" in binary! at ${rdr.getLocStr()}';
						}
					}

					eatEmpty(rdr);
				}

				Token.TBinary(out.toString(), 2);
		} else if((match = rdr.tryMatchRx(~/(?:16)?#\{/)) != null) { // [_]
			final out = new StringBuf();

				eatEmpty(rdr);

				while(!rdr.tryMatch("}")) {
					switch rdr.next(2) {
						case c if(~/^[a-fA-F\d]{2}$/.match(c)): out.add(c);
						case c: throw 'Unexpected character "$c" in binary! at ${rdr.getLocStr()}';
					}

					eatEmpty(rdr);
				}

				Token.TBinary(out.toString(), 16);
		} else if(rdr.tryMatch("64#{")) {
			final out = new StringBuf();

				eatEmpty(rdr);

				while(!rdr.tryMatch("}")) {
					switch rdr.next() {
						case c if(~/^[a-zA-Z\d=\/+]$/.match(c)): out.add(c);
						case c: throw 'Unexpected character "$c" in binary! at ${rdr.getLocStr()}';
					}

					eatEmpty(rdr);
				}

				Token.TBinary(out.toString(), 64);
		} else if(rdr.matches("(")) {
			Token.TParen(Actions.paren(rdr));
		} else if(rdr.matches("[")) {
			Token.TBlock(Actions.block(rdr));
		} else if(rdr.matches("#(")) {
			Token.TMap(Actions.map(rdr));
		} else if(rdr.matches("#[")) {
			Token.TConstruct(Actions.construct(rdr));
		} else {
			throw 'Syntax error: Invalid token "${rdr.peek()}" near "${rdr.stream.substr(rdr.pos, 5)}" at ${rdr.getLocStr()}';
		}
		
		/*final res = switch rdr {
			case _.tryMatchRx(Regexps.div) => [word]:
				Token.TWord(word);
			case _.tryMatchRx(Regexps.getDiv) => [_, word]:
				Token.TGetWord(word);
			case _.tryMatchRx(Regexps.litDiv) => [_, word]:
				Token.TLitWord(word);
			case _.tryMatchRx(Regexps.setDiv) => [_, word]:
				Token.TSetWord(word);
			case matchRxWithGuard(_, RegexpChecks.refinement, Regexps.refinement) => [_, refine]:
				Token.TRefinement(refine);
			case _.tryMatchRx(Regexps.hexa) => [_, hexa]:
				Token.TInteger(Util.mustParseInt('0x$hexa'));
			// skip email for now
			case matchRxWithGuardRx(_, RegexpChecks.file, Regexps.file) => [_, file]:
				Token.TFile(file);
			case matchRxWithGuardRx(_, RegexpChecks.url, Regexps.url) => [_, url]:
				Token.TUrl(url);
			// skip money for now
			case matchRxWithGuardRx(_, RegexpChecks.word, Regexps.word) => [word]:
				if(rdr.tryMatch(":")) {
					Token.TSetWord(word);
				} else if(rdr.peek() == "/") {
					final path = Actions.path(rdr, Token.TWord(word));
					if(rdr.tryMatch(":")) {
						Token.TSetPath(path);
					} else {
						Token.TPath(path);
					}
				} else {
					Token.TWord(word);
				}
			case _.tryMatchRx(RegexpChecks.specialWord) => [word]:
				if(rdr.tryMatch(":")) {
					Token.TSetWord(word);
				} else {
					Token.TWord(word);
				}
			case _.tryMatch(":") => true:
				switch rdr {
					case matchRxWithGuardRx(_, RegexpChecks.word, Regexps.word) => [word]:
						if(rdr.peek() == ":") {
							throw "error!";
						} else if(rdr.peek() == "/") {
							final path = Actions.path(rdr, TWord(word));
							if(rdr.peek() == ":") {
								throw "error!";
							} else {
								Token.TGetPath(path);
							}
						} else {
							Token.TGetWord(word);
						}
					case _.tryMatchRx(RegexpChecks.specialWord) => [word]:
						if(rdr.peek() == ":") {
							throw "error!";
						} else {
							Token.TGetWord(word);
						}
					default: throw "error!";
				}
			case _.tryMatch("'") => true:
				switch rdr {
					case matchRxWithGuardRx(_, RegexpChecks.word, Regexps.word) => [word]:
						if(rdr.peek() == ":") {
							throw "error!";
						} else if(rdr.peek() == "/") {
							final path = Actions.path(rdr, TWord(word));
							if(rdr.peek() == ":") {
								throw "error!";
							} else {
								Token.TLitPath(path);
							}
						} else {
							Token.TLitWord(word);
						}
					case _.tryMatchRx(RegexpChecks.specialWord) => [word]:
						if(rdr.peek() == ":") {
							throw "error!";
						} else {
							Token.TLitWord(word);
						}
					default: throw "error!";
				}
				
			case matchRxWithGuardRx(_, RegexpChecks.issue, Regexps.issue) => [_, issue]:
				Token.TIssue(issue);
			case matchRxWithGuardRx(_, RegexpChecks.pair, Regexps.pair) => [_, x, y]:
				Token.TPair(Util.mustParseInt(x), Util.mustParseInt(y));
			case matchRxWithGuardRx(_, RegexpChecks.time, Regexps.time) => [_, h, m, s]:
				Token.TTime(Util.mustParseInt(h), Util.mustParseInt(m), if(s == null) 0 else Std.parseFloat(s));
			case _.matchesRx(RegexpChecks.date) => true:
				throw "todo!";
			case matchRxWithGuardRx(_, RegexpChecks.float, Regexps.float) => [Std.parseFloat(_) => float]:
				if(rdr.tryMatch("%")) {
					Token.TPercent(float);
				} else {
					Token.TFloat(float);
				}
			case matchRxWithGuardRx(_, RegexpChecks.integer, Regexps.integer) => [Util.mustParseInt(_) => integer]:
				if(rdr.tryMatch("%")) {
					Token.TPercent(integer);
				} else {
					Token.TInteger(integer);
				}
			case matchRxWithGuardRx(_, RegexpChecks.tuple, Regexps.tuple) => match if(match != null):
				Token.TTuple(match.slice(1).map(Util.mustParseInt));
			case matchRxWithGuard(_, RegexpChecks.char, Regexps.char) => [_, char]:
				Token.TChar(char);
			case matchRxWithGuard(_, RegexpChecks.string, Regexps.string) => [_, string]:
				Token.TString(string);
			case _.tryMatch(RegexpChecks.multiString) => true:
				final out = new StringBuf();
				var level = 1;

				while(level > 0) {
					if(rdr.eof()) {
						throw 'Syntax error: Invalid string! at "$out"';
					}

					switch rdr.next() {
						case "{":
							out.add("{");
							level++;
						case "}" if(level > 0):
							out.add("}");
							level--;
						case "}":
							break;
						case "^":
							out.add(switch rdr.next() {
								case c = "{" | "}": c;
								case c: '^$c';
							});
						case c:
							out.add(c);
					}
				}

				Token.TString(out.toString());
			case matchRxWithGuardRx(_, RegexpChecks.tag, Regexps.tag) => [_, tag]:
				Token.TTag(tag);
			case _.tryMatch("2#{") => true:
				final out = new StringBuf();

				eatEmpty(rdr);

				while(!rdr.tryMatch("}")) {
					for(i in 0...8) {
						switch rdr.next() {
							case c = "0" | "1": out.add(c);
							case c: throw 'Unexpected character "$c" in binary!';
						}
					}

					eatEmpty(rdr);
				}

				Token.TBinary(out.toString(), 2);
			case _.tryMatchRx(~/(?:16)?#\{/) => [_]:
				final out = new StringBuf();

				eatEmpty(rdr);

				while(!rdr.tryMatch("}")) {
					switch rdr.next(2) {
						case c if(~/^[a-fA-F\d]{2}$/.match(c)): out.add(c);
						case c: throw 'Unexpected character "$c" in binary!';
					}

					eatEmpty(rdr);
				}

				Token.TBinary(out.toString(), 16);
			case _.tryMatch("64#{") => true:
				final out = new StringBuf();

				eatEmpty(rdr);

				while(!rdr.tryMatch("}")) {
					switch rdr.next() {
						case c if(~/^[a-zA-Z\d=\/+]$/.match(c)): out.add(c);
						case c: throw 'Unexpected character "$c" in binary!';
					}

					eatEmpty(rdr);
				}

				Token.TBinary(out.toString(), 64);
			case _.matches("(") => true: Token.TParen(Actions.paren(rdr));
			case _.matches("[") => true: Token.TBlock(Actions.block(rdr));
			case _.matches("#(") => true: Token.TMap(Actions.map(rdr));
			case _.matches("#[") => true: Token.TConstruct(Actions.construct(rdr));
			default:
				final loc = rdr.getLoc();
				throw 'Syntax error: Invalid token "${rdr.peek()}" near "${rdr.stream.substr(rdr.pos, 5)}" at [${loc.line}:${loc.column}]';
		};*/

		eatEmpty(rdr);

		return res;
	}

	public static function tokenize(input: String) {
		if(Actions.makeNext == null) Actions.makeNext = makeNext;
		
		final rdr = new Reader(input);
		final out = [];
		
		while(!rdr.eof()) {
			out.push(makeNext(rdr));
		}
		
		return out;
	}

	static function tokenToValue(token: Token): types.Value {
		return switch token {
			case TWord(word): new types.Word(word);
			case TGetWord(word): new types.GetWord(word);
			case TSetWord(word): new types.SetWord(word);
			case TLitWord(word): new types.LitWord(word);
			case TPath(path): new types.Path(path.map(tokenToValue));
			case TGetPath(path): new types.GetPath(path.map(tokenToValue));
			case TSetPath(path): new types.SetPath(path.map(tokenToValue));
			case TLitPath(path): new types.LitPath(path.map(tokenToValue));
			case TInteger(int): new types.Integer(int);
			case TFloat(float): new types.Float(float);
			case TPercent(percent): new types.Percent(percent / 100);
			case TMoney(_, _): throw 'NYI';
			case TChar(char): types.Char.fromRed(char);
			case TString(str): types.String.fromRed(str);
			case TFile(file): new types.File(types.base._String.charsFromRed(file));
			case TEmail(email): new types.Email(types.base._String.charsFromRed(email));
			case TUrl(url): new types.Url(types.base._String.charsFromRed(url));
			case TIssue(issue): new types.Issue(issue);
			case TRefinement(ref): new types.Refinement(ref);
			case TTag(tag): new types.Tag(types.base._String.charsFromRed(tag));
			case TRef(ref): new types.Ref(types.base._String.charsFromRed(ref));
			case TBinary(_, _): throw 'NYI';
			case TBlock(block): new types.Block(block.map(tokenToValue));
			case TParen(paren): new types.Paren(paren.map(tokenToValue));
			case TMap(map): types.Map.fromPairs([for(i => k in map) if(i % 2 == 0) {k: tokenToValue(k), v: tokenToValue(map[i + 1])}]);
			case TTuple(tuple): new types.Tuple(new util.UInt8ClampedArray(tuple));
			case TPair(x, y): new types.Pair(x, y);
			case TDate(_, _, _): throw 'NYI';
			case TTime(h, m, s): types.Time.fromHMS(h, m, s);
			case TConstruct([TWord("true")]): types.Logic.TRUE;
			case TConstruct([TWord("false")]): types.Logic.FALSE;
			case TConstruct([TWord("none" | "none!")]): types.None.NONE;
			case TConstruct(_): throw 'NYI';
		}
	}

	public static function parse(input: String) {
		return tokenize(input).map(tokenToValue);
	}
}
