package tokenizer;

import Util.jsRx;

@:publicFields
class RegexpChecks {
	static final wordMoney = jsRx(~/([+-]?)([a-zA-Z]{1,3})/, "y");
//							 ~/(?:[a-zA-Z_*=>&|!?~`^]|<+(?=[-:=>\[\](){}l^"\s!]|$)|(?:\.|[+-]\.?)(?!\d))(?:[\w+\-*=>&|!?~`\.'^]|<(?!<))*/
	static final word = jsRx(~/(?:[a-zA-Z_*=>&|!?~`^]+|<+(?=[-:=>\[\](){}l^"\s!]|$)|(?:\.|[+-]\.?)(?!\d))(?:[\w+\-*=>&|!?~`\.'^]|<(?!<))*/, "y");
	static final hexa = jsRx(~/([A-F\d]{2,})h/, "y");
	static final integer = jsRx(~/[+-]?\d+\b(?!\.|#\{)/, "y");
	static final specialFloat = jsRx(~/[+-]?1\.#/, "y");
	static final float = jsRx(~/[+-]?(?:\d*\.\d+(?![\.\d])|\d+\.(?!\d+\.)|\d+[eE][+-]?\d+)/, "y");
	static final money = jsRx(~/[+-]?[a-zA-Z]{0,3}\$\d/, "y");
	static final string = '"';
	static final file = jsRx(~/%(?![\s%:;()\[\]{}])/, "y");
	static final email = jsRx(~/[\w\.]+@/, "y"); // not perfect
	static final url = jsRx(~/[a-zA-Z_]+:[^\s]/, "y"); // very lazy for now
	static final char = '#"';
	static final issue = jsRx(~/#(?!["\/()\[\]{}:;@\s])/, "y");
	static final specialWord = jsRx(~/%+(?=[\s()\[\]<>:]|$)/, "y");
	static final time = jsRx(~/[+-]?\d+:\d/, "y");
	static final pair = jsRx(~/[+-]?\d+[xX]/, "y");
	static final tuple = jsRx(~/(?:\d+\.){2}/, "y");
	static final point = jsRx(~/\(\d+(?:\.(?:#Inf|#NaN|\d+(?:[eE][+-]?\d+)?)|e[+-]?\d+)?\s*,\s/, "y");
	static final tag = jsRx(~/<[^-=>\[\](){}l^"\s](?:"[^"]*"|'[^']*'|[^>"']+)*/, "y");
	static final ref = "@";
	static final refinement = "/";
	static final date = jsRx(~/\d+[\/\-T]/, "y");
	static final paren = "(";
	static final block = "[";
	static final multiString = "{";
	static final map = "#(";
	static final construct = "#[";
	static final binary = jsRx(~/(?:2|16|64)?#\{/, "y");
	static final rawString = jsRx(~/%+\{/, "y");
}
