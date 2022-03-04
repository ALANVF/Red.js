package types.base;

using StringTools;
using util.StringTools;

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

abstract class _String extends _SeriesOf<Char> {
	public static function charsFromRed(str: std.String) {
		return [while(str.length > 0) {
			var code = 0, len = 0;
			if(str.charCodeAt(0) == "^".code) {
				Util._match(str.charCodeAt(1).nonNull(),
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
					},

					at(esc = ("A".code ... "Z".code)) => {code = esc - 64; len = 2;},
					at(esc = ("a".code ... "z".code)) => {code = esc - 32 - 64; len = 2;},

					_ => throw 'Invalid string! escape "^${str.charAt(1)}"!'
				);
			} else {
				code = str.charCodeAt(0); len = 1;
			};

			str = str.substr(len);
			Char.fromCode(code);
		}];
	}

	public function toJs() {
		return std.String.fromCharCodes((index == 0 ? values : values.slice(index)).map(c -> c.int));		
	}
}