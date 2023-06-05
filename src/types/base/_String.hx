package types.base;

using StringTools;

macro function inlineMap(kIdent, vIdent, mapExpr, body) {
	final kName = switch kIdent { case macro $i{n}: n; default: throw "error!"; };
	final vName = switch vIdent { case macro $i{n}: n; default: throw "error!"; };
	final map = switch mapExpr { case macro [$a{m}]: m; default: throw "error!"; };

	function mapBody(k, kv, v, vv, e: haxe.macro.Expr) return switch e {
		case macro $i{name} if(name == k): macro $kv;
		case macro $i{name} if(name == v): macro $vv;
		default: haxe.macro.ExprTools.map(e, mapBody.bind(k, kv, v, vv, _));
	}

	function mapCases(pairs: Array<haxe.macro.Expr>) {
		return if(pairs.length == 0) {
			macro {};
		} else switch pairs[0] {
			case macro $k => $v:
				final b = mapBody(kName, k, vName, v, body);
				if(pairs.length == 1) {
					macro if(nstr.startsWith($k)) $b;
				} else {
					macro if(nstr.startsWith($k)) $b else ${mapCases(pairs.slice(1))};
				}

			default: haxe.macro.Context.error("error!", pairs[0].pos);
		}
	}

	return mapCases(map);
}

abstract class _String extends _SeriesOf<Char, Int> {
	// TODO: optimize this whole mapping functionality eventually
	public static function codesFromRed(str: std.String) {
		return [while(str.length > 0) {
			var code = 0, len = 0;
			if(str.cca(0) == "^".code) {
				Util._match(str.cca(1).nonNull(),
					at(c = ('"'.code | "^".code)) => {code = c; len = 2;},
					at("\\".code) => {code = 28; len = 2;},
					at("]".code) => {code = 29; len = 2;},
					at("_".code) => {code = 31; len = 2;},

					at("@".code) => {code = 0; len = 2;},
					at("-".code) => {code = 9; len = 2;},
					at("/".code) => {code = 10; len = 2;},
					at("[".code) => {code = 27; len = 2;},
					at("~".code) => {code = 127; len = 2;},

					at("(".code) => {
						final nstr = str.substr(2).toUpperCase();
						var res = null;

						inlineMap(k, v, [
							"NULL)" => 0,
							"BACK)" => 8,
							"TAB)" => 9,
							"LINE)" => 10,
							"PAGE)" => 12,
							"ESC)" => 27,
							"DEL)" => 127
						], {
							res = code = v;
							len = 2 + k.length;
						});

						res ?? {
							final rx = ~/^([A-F\d]+)\)/i;
							if(rx.match(nstr)) {
								code = Util.mustParseInt("0x" + rx.matched(0)); len = 2 + rx.matchedPos().len;
							} else {
								throw 'Invalid string! escape "^${str.charAt(1)}"!';
							}
						};
					},

					at(esc = ("A".code ... "Z".code)) => {code = esc - 64; len = 2;},
					at(esc = ("a".code ... "z".code)) => {code = esc - 32 - 64; len = 2;},

					_ => throw 'Invalid string! escape "^${str.charAt(1)}"!'
				);
			} else {
				code = str.cca(0); len = 1;
			};

			str = str.substr(len);
			code;
		}];
	}

	public static function charsFromRed(str: std.String) {
		final codes: Array<Any> = codesFromRed(str);
		for(i in 0...codes.length) codes[i] = Char.fromCode(codes[i]);
		return (cast codes : Array<Char>);
	}

	public function toJs() {
		return std.String.fromCharCodes((index == 0 ? values : values.slice(index)));		
	}

	function wrap(value: Int) return Char.fromCode(value);
	function unwrap(value: Char) return value.int;


	public function append(value: _String, limit: Null<Int>) {
		values.pushAll(
			Util._andOr(limit, limit => {
				if(value.index == 0) value.values.slice(0, value.index + limit);
				else value.values.slice(value.index, value.index + limit);
			}, {
				if(value.index == 0) value.values;
				else value.values.slice(value.index);
			})
		);
	}

	public function appendLiteral(value: std.String) {
		for(i in 0...value.length) {
			values.push(value.cca(i));
		}
	}

	public function appendLiteralPart(value: std.String, part: Int) {
		for(i in 0...part) {
			values.push(value.cca(i));
		}
	}

	public inline function appendChar(char: Int) {
		values.push(char);
	}

	public function appendEscapedChar(char: Int, isEsc: Bool, isAll: Bool) {
		if(char == 0x1e || (0x80 <= char && char <= 0x9f) || (isAll && char > 0x7f)) {
			appendChar('^'.code);
			appendChar('('.code);
			appendLiteral(char.toString(16).padStart(2, "0"));
			appendChar(')'.code);
		} else if(isEsc) {
			final c = Util._match(char,
				at((0 ... 7) | 11 | (13 ... 31)) => char + 64,
				at(9) => '-'.code,
				at(10) => '/'.code,
				at(34) => '"'.code,
				at(94 | 0x7f) => '^'.code,
				_ => -1 
			);
			if(c == -1) {
				appendChar(char);
			} else {
				appendChar('^'.code);
				appendChar(c);
			}
		} else {
			appendChar(char);
		}
	}
}