package tokenizer;

import Util.jsRx;

@:publicFields
class Regexps {
	static final wordMoney = jsRx(~/([+-]?)([a-zA-Z]{1,3})/, "y");
	static final wordEmail = jsRx(~/([a-zA-Z\.\-]+)/, "y");
	static final word = jsRx(~/(?:[a-zA-Z_*=>&|!?~`^]|<+(?=[-:=>\[\](){}l^"\s!]|$)|(?:\.|[+-]\.?)(?!\d))(?:[\w+\-*=>&|!?~`\.'^]|<(?!<))*/, "y");
	static final hexa = jsRx(~/([A-F\d]{2,})h/, "y");
	static final integer = jsRx(~/[+-]?\d+\b(?!\.|#\{)/, "y");
	static final nanFloat = jsRx(~/[+-]?1\.#NaN\b/i, "y");
	static final infFloat = jsRx(~/([+-]?)1\.#Inf\b/i, "y");
	static final float = jsRx(~/[+-]?(?:(?:\d*\.\d+(?!\.)|\d+\.(?!\d+\.))(?:[eE][+-]?\d+)?|\d+[eE][+-]?\d+)/, "y");
	static final money = jsRx(~/([+-]?)([a-zA-Z]{0,3})\$(\d+(?:\.\d+)?)/, "y");
	static final string = jsRx(~/"((?:\^.|[^"^]+)*)"/, "y");
	static final file = jsRx(~/%(?![\s%:;()\[\]{}])(?:([^\s;"]+)|"((?:\^.|[^"^]+)*)")/, "y");
	static final email = jsRx(~/[\w\.]+@[\w\.]+/, "y"); // not perfect
	static final url = jsRx(~/[a-zA-Z_]+:[^\s]+/, "y"); // very lazy for now
	static final char = jsRx(~/#"(\^(?:[A-Z\[\]\\_@\-\/~"^]|\((?:[A-F\d]+|null|back|tab|line|page|esc|del)\))|.)"/i, "y");
	static final issue = jsRx(~/#(?!["\/()\[\]{}:;@\s])([^"\/()\[\]{}:;@\s]+)/, "y");
	static final specialWord = jsRx(~/(%+)(?=[\s()\[\]<>:]|$)/, "y");
	static final time = jsRx(~/([+-]?\d+):(\d+)(?::(\d+(?:\.\d+)?))?/, "y");
	static final pair = jsRx(~/([+-]?\d+)[xX]([+-]?\d+)/, "y");
	static final tuple = jsRx(~/(\d+)\.(\d+)\.(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?/, "y");
	static final pointComma = jsRx(~/\s*,\s+/, "y");
	static final tag = jsRx(~/<([^-=>\[\](){}l^"\s](?:"[^"]*"|'[^']*'|[^>])*)>/, "y");
	static final ref = jsRx(~/@([^#$',=>@\\^"(, "y");<\[\]{}\s]*)/, "y");
	static final refinement = jsRx(~/\/([^\/\\^,\[\](){}"#$%@:;\s]+)/, "y");
	static final beginParen = "(";
	static final beginBlock = "[";
	static final beginMultiString = "{";
	static final beginMap = "#(";
	static final beginConstruct = "#[";
	static final beginBinary = jsRx(~/(2|16|64)?#\{/, "y");
	static final beginRawString = jsRx(~/(%+)\{/, "y");
	static final comment = jsRx(~/;.*$/m, "y");
	
	static final div = jsRx(~/\/\/?(?=[\s()\[\]]|$)/, "y");
	static final getDiv = jsRx(~/:(\/\/?)/, "y");
	static final litDiv = jsRx(~/'(\/\/?)/, "y");
	static final setDiv = jsRx(~/(\/\/?):/, "y");

	// copied directly from the old typescript impl
	static final date = {
		final anyCase = (str: String) -> (js.Syntax.code("[...{0}]", str) : Array<String>).map(ch -> '[${ch}${ch.toUpperCase()}]').join("");
		final rule = (str: String) -> str.replace(jsRx(~/\s+/gm), "");
		
		// Basic rules
		final sep = "[/-]";
		final yyyy = "\\d{3,4}";
		final yy = "\\d{1,2}";
		final m = "1[012]|0?[1-9]";
		final mm = "1[012]|0[1-9]";
		final mon = "jan feb mar apr may jun jul aug sep oct nov dec".split(" ")._map(anyCase).join("|");
		final month = "january february march april may june july august september october november december".split(" ")._map(anyCase).join("|");
		final d = "[1-7]";
		final dd = "3[01]|[12]\\d|0?[1-9]";
		final ddd = "36[0-6]|3[0-5]\\d|[12]\\d{2}|0\\d[1-9]|0[1-9]\\d";
		final ww = "5[012]|[1-4]\\d|0[1-9]";
		final hour = "\\d{1,2}";
		final min = "\\d{1,2}";
		final ss = "\\d{1,2}";
		final dec = "\\d+";
		final sign = "[+-]";
		final min15 = "\\d{1,2}";
		final hhmm = "\\d{4}";
		final hhmmss = "\\d{6}";

		// Compound rules:
		final sec = rule('
			${ss}
			(?:
				\\.
				${dec}
			)?
		');

		final zone = rule('
			(?<zone_sign> ${sign})
			(?:
				(?<zone_hm15>
					(?<zone_hm15_hour> ${hour})
					:
					(?<zone_hm15_min15> ${min15})
				)
				| (?<zone_hour> ${hour}\\b)
				| (?<zone_hhmm> ${hhmm})
			)
		');

		final time = rule('
			(?<time_hms>
				(?<time_hms_hour> ${hour})
				:
				(?<time_hms_min> ${min})
				(?:
					:
					(?<time_hms_sec> ${sec})
				)?
			)
			| (?<time_hhmmss>
				(?<time_hhmmss_hhmmss> ${hhmmss})
				(?:
					\\.
					(?<time_hhmmss_dec> ${dec})
				)?
			)
			| (?<time_hhmm> ${hhmm})
		');

		final mmm = (outer: String) -> rule('
			(?<${outer}_mmm_m> ${m})
			| (?<${outer}_mmm_mon> ${mon})
			| (?<${outer}_mmm_month> ${month})
		');

		final date = rule('
			(?<date_yyyymmmdd>
				(?<date_yyyymmmdd_yyyy> ${yyyy})
				${sep}
				(?<date_yyyymmmdd_mmm> ${mmm("date_yyyymmmdd")})
				${sep}
				(?<date_yyyymmmdd_dd> ${dd})
			)
			| (?<date_ddmmmy>
				(?<date_ddmmmy_dd> ${dd})
				${sep}
				(?<date_ddmmmy_mmm> ${mmm("date_ddmmmy")})
				${sep}
				(?:
					(?<date_ddmmmy_yyyy> ${yyyy})
					| (?<date_ddmmmy_yy> ${yy})
				)
			)
			| (?<date_yyyyddd>
				(?<date_yyyyddd_yyyy> ${yyyy})
				-
				(?<date_yyyyddd_ddd> ${ddd})
			)
			| (?<date_yyyyW>
				(?<date_yyyyW_yyyy> ${yyyy})
				-W
				(?<date_yyyyW_ww> ${ww})
				(?:
					-
					(?<date_yyyyW_d> ${d})
				)?
			)
		');

		final dateT = rule('
			(?<dateT_yyyy> ${yyyy})
			(?<dateT_mm> ${mm})
			(?<dateT_dd> ${dd})
		');

		final main = rule('
			(?:
				(?<date> ${date})
				| (?<dateT> ${dateT}) (?=T)
			)
			(?:
				[/T]
				(?<time> ${time})
				(?:
					(?<Z> Z)
					| (?<zone> ${zone})
				)?
			)?
		');

		new js.lib.RegExp(main, "y");
	};
}
