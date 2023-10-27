package tokenizer;

import Util.jsRx;

@:publicFields
class Regexps {
	static final wordMoney = jsRx(~/([+-]?)([a-zA-Z]{1,3})/, "y");
	static final wordEmail = jsRx(~/([a-zA-Z\.\-]+)/, "y");
	static final word = jsRx(~/(?:[a-zA-Z_*=>&|!?~`^]|<+(?=[-:=>\[\](){}l^"\s]|$)|(?:\.|[+-]\.?)(?!\d))(?:[\w+\-*=>&|!?~`\.'^]|<(?!<))*/, "y");
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
}
