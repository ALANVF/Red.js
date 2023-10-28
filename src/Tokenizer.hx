import types.Point2D;
import tokenizer.*;
//import tokenizer.Token;
import js.lib.RegExp;
import Util.jsRx;

class Tokenizer {
	static function matchRxWithGuardRx(rdr: Reader, guard: RegExp, rx: RegExp) {
		return if(rdr.matchesRx(guard)) {
			rdr.matchRx(rx);
		} else {
			null;
		}
	}

	static function matchRxWithGuard(rdr: Reader, guard: String, rx: RegExp) {
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
		
		var match: Null<js.lib.RegExp.RegExpMatch> = null;
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
			Token.TFile(match[1] ?? match[2]);
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.url, Regexps.url)) != null) { // [_, url]
			Token.TUrl(match[0]);
		} else if(rdr.tryMatch("-$") && (
			(match = matchRxWithGuardRx(rdr, RegexpChecks.float, Regexps.float)) != null
			|| (match = matchRxWithGuardRx(rdr, RegexpChecks.integer, Regexps.integer)) != null
		)) {
			Token.TMoney("-" + match[0]);
		} else if((rdr.tryMatch("$") || rdr.tryMatch("+$")) && (
			(match = matchRxWithGuardRx(rdr, RegexpChecks.float, Regexps.float)) != null
			|| (match = matchRxWithGuardRx(rdr, RegexpChecks.integer, Regexps.integer)) != null
		)) {
			Token.TMoney(match[0]);
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.wordMoney, Regexps.wordMoney)) != null) {
			final neg = match[1];
			final region = match[2];
			if(rdr.tryMatch("$")) {
				// TODO: add check for sign here
				if((match = matchRxWithGuardRx(rdr, RegexpChecks.float, Regexps.float)) != null
				|| (match = matchRxWithGuardRx(rdr, RegexpChecks.integer, Regexps.integer)) != null) {
					Token.TMoney(neg + match[0], region);
				} else {
					throw "Invalid money!";
				}
			} else {
				@:privateAccess rdr.pos -= region.length + neg.length;
				if((match = matchRxWithGuardRx(rdr, RegexpChecks.word, Regexps.word)) != null) {
					final word = match[0];
					Actions.word(rdr, word);
				} else {
					throw "Invalid word!";
				}
			}
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.word, Regexps.word)) != null) { // [word]
			final word = match[0];
			Actions.word(rdr, word);
		} else if((match = rdr.tryMatchRx(Regexps.specialWord)) != null) { // [word]
			final word = match[0];
			if(rdr.tryMatch(":")) {
				Token.TSetWord(word);
			} else {
				Token.TWord(word);
			}
		} else if(rdr.tryMatch(":")) {
			switch rdr {
				case matchRxWithGuardRx(_, RegexpChecks.word, Regexps.word) => (cast _ : Null<Array<String>>) => [word]:
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
				case _.tryMatchRx(Regexps.specialWord) => (cast _ : Null<Array<String>>) => [word]:
					if(rdr.peek() == ":") {
						throw "error!";
					} else {
						Token.TGetWord(word);
					}
				default: throw "error!";
			}
		} else if(rdr.tryMatch("'")) {
			switch rdr {
				case matchRxWithGuardRx(_, RegexpChecks.word, Regexps.word) => (cast _ : Null<Array<String>>) => [word]:
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
				case _.tryMatchRx(Regexps.specialWord) => (cast _ : Null<Array<String>>) => [word]:
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
		} else if(rdr.matchesRx(RegexpChecks.specialFloat)) {
			Token.TFloat(Actions.specialFloat(rdr) ?? throw "Invalid float literal!");
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
			Token.TTuple(match.slice(1, end == -1 ? null : end).map(v -> Util.mustParseInt(v)));
		} else if((match = matchRxWithGuard(rdr, RegexpChecks.char, Regexps.char)) != null) { // [_, char]
			Token.TChar(match[1]);
		} else if((match = matchRxWithGuard(rdr, RegexpChecks.string, Regexps.string)) != null) { // [_, string]
			Token.TString(match[1]);
		} else if(rdr.tryMatch(RegexpChecks.multiString)) {
			var out = "";
			var level = 1;

			while(level > 0) {
				if(rdr.eof()) {
					throw 'Syntax error: Invalid string! near "$out"  at ${rdr.getLocStr()}';
				}

				switch rdr.next() {
					case "{":
						out += "{";
						level++;
					case "}" if(level > 0):
						out += "}";
						level--;
					case "}":
						break;
					case "^":
						out += switch rdr.next() {
							case c = "{" | "}": c;
							case c: '^$c';
						};
					case c:
						out += c;
				}
			}

			Token.TString(out);
		} else if((match = rdr.tryMatchRx(Regexps.beginRawString)) != null) {
			final end = "}" + match[1];

			rdr.matchSubstr(end)._andOr(str => {
				Token.TRawString(str);
			}, {
				throw "Invalid string literal";
			});
		} else if((match = matchRxWithGuardRx(rdr, RegexpChecks.tag, Regexps.tag)) != null) { // [_, tag]
			Token.TTag(match[1]);
		} else if(rdr.tryMatch("2#{")) {
			var out = "";

			eatEmpty(rdr);

			while(!rdr.tryMatch("}")) {
				for(_ in 0...8) {
					switch rdr.next() {
						case c = "0" | "1": out += c;
						case c: throw 'Unexpected character "$c" in binary! at ${rdr.getLocStr()}';
					}
				}

				eatEmpty(rdr);
			}

			Token.TBinary(out, 2);
		} else if((match = rdr.tryMatchRx(jsRx(~/(?:16)?#\{/))) != null) { // [_]
			var out = "";

			eatEmpty(rdr);

			while(!rdr.tryMatch("}")) {
				switch rdr.next(2) {
					case c if(jsRx(~/[a-fA-F\d]{2}$/).test(c)): out += c;
					case c: throw 'Unexpected character "$c" in binary! at ${rdr.getLocStr()}';
				}

				eatEmpty(rdr);
			}

			Token.TBinary(out, 16);
		} else if(rdr.tryMatch("64#{")) {
			var out = "";

			eatEmpty(rdr);

			while(!rdr.tryMatch("}")) {
				switch rdr.next() {
					case c if(jsRx(~/[a-zA-Z\d=\/+]$/).test(c)): out += c;
					case c: throw 'Unexpected character "$c" in binary! at ${rdr.getLocStr()}';
				}

				eatEmpty(rdr);
			}

			Token.TBinary(out, 64);
		} else if(rdr.matches("(")) {
			Actions.parenOrPoint(rdr);
		} else if(rdr.matches("[")) {
			Token.TBlock(Actions.block(rdr));
		} else if(rdr.matches("#(")) {
			Token.TMap(Actions.map(rdr));
		} else if(rdr.matches("#[")) {
			Token.TConstruct(Actions.construct(rdr));
		} else {
			throw 'Syntax error: Invalid token "${rdr.peek()}" near "${rdr.stream._substr(rdr.pos, 5)}" at ${rdr.getLocStr()}';
		}
		
		eatEmpty(rdr);

		return res;
	}

	public static function tokenize(input: String) {
		Actions.makeNext ??= makeNext;
		
		final rdr = new Reader(input);
		final out = [];
		
		while(!rdr.eof()) {
			out.push(makeNext(rdr));
		}
		
		return out;
	}

	static function tokenToValue(token: Token): types.Value {
		return switch token {
			case TWord(word): new types.Word(types.base.Symbol.make(word));
			case TGetWord(word): new types.GetWord(types.base.Symbol.make(word));
			case TSetWord(word): new types.SetWord(types.base.Symbol.make(word));
			case TLitWord(word): new types.LitWord(types.base.Symbol.make(word));
			case TPath(path): new types.Path(path.map(tokenToValue));
			case TGetPath(path): new types.GetPath(path.map(tokenToValue));
			case TSetPath(path): new types.SetPath(path.map(tokenToValue));
			case TLitPath(path): new types.LitPath(path.map(tokenToValue));
			case TInteger(int): new types.Integer(int);
			case TFloat(float): new types.Float(float);
			case TPercent(percent): new types.Percent(percent / 100);
			case TMoney(money, region):
				new types.Money(
					util.Dec64.fromString(money),
					if(region == null || region == "") null else new types.Word(types.base.Symbol.make(region))
				);
			case TChar(char): types.Char.fromRed(char);
			case TString(str): types.String.fromRed(str);
			case TRawString(str): types.String.fromString(str);
			case TFile(file): new types.File(types.base._String.codesFromRed(file));
			case TEmail(email): new types.Email(types.base._String.codesFromRed(email));
			case TUrl(url): new types.Url(types.base._String.codesFromRed(url));
			case TIssue(issue): new types.Issue(types.base.Symbol.make(issue));
			case TRefinement(ref): new types.Refinement(types.base.Symbol.make(ref));
			case TTag(tag): new types.Tag(types.base._String.codesFromRed(tag));
			case TRef(ref): new types.Ref(types.base._String.codesFromRed(ref));
			case TBinary(binary, 2): new types.Binary(js.Syntax.code("{0}.match(/.{{8}/g).map(x => parseInt(x, 2))", binary));
			case TBinary(binary, 16): new types.Binary(js.Syntax.code("{0}.match(/../g).map(x => parseInt(x, 16))", binary));
			case TBinary(binary, 64): new types.Binary(js.Syntax.code("[...atob({0})].map(c => c.charCodeAt())", binary));
			case TBinary(_, _): throw "bad";
			case TBlock(block): new types.Block(block.map(v -> tokenToValue(v)));
			case TParen(paren): new types.Paren(paren.map(v -> tokenToValue(v)));
			case TMap(map): new types.Map([for(i => v in map) {
				final value = tokenToValue(v);
				if(i % 2 == 0) types.Map.preprocessKey(value) else value;
			}]);
			case TTuple(tuple): new types.Tuple(new util.UInt8ClampedArray(tuple));
			case TPair(x, y): new types.Pair(x, y);
			case TPoint2D(x, y): new types.Point2D(x, y);
			case TPoint3D(x, y, z): new types.Point3D(x, y, z);
			case TDate(_, _, _): throw 'NYI';
			case TTime(h, m, s): types.Time.fromHMS(h, m, s);
			case TConstruct([TWord("true")]): types.Logic.TRUE;
			case TConstruct([TWord("false")]): types.Logic.FALSE;
			case TConstruct([TWord("none" | "none!")]): types.None.NONE;
			case TConstruct(_): throw 'NYI';
		}
	}

	public static function parse(input: String) {
		return tokenize(input).map(v -> tokenToValue(v));
	}
}
