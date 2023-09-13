package tokenizer;

@:publicFields
class Regexps {
	static final word = ~/^(?:[a-zA-Z_*=>&|!?~`^]|<+(?=[-:=>\[\](){}l^"\s]|$)|(?:\.|[+-]\.?)(?!\d))(?:[\w+\-*=>&|!?~`\.'^]|<(?!<))*/;
	static final hexa = ~/^([A-F\d]{2,})h/;
	static final integer = ~/^[+-]?\d+\b(?!\.|#\{)/;
	static final nanFloat = ~/^[+-]?1\.#NaN\b/i;
	static final infFloat = ~/^([+-]?)1\.#Inf\b/i;
	static final float = ~/^[+-]?(?:(?:\d*\.\d+(?!\.)|\d+\.(?!\d+\.))(?:[eE][+-]?\d+)?|\d+[eE][+-]?\d+)/;
	static final money = ~/^([+-]?)([a-zA-Z]{0,3})\$(\d+(?:\.\d+)?)/;
	static final string = ~/^"((?:\^.|[^"^]+)*)"/;
	static final file = ~/^%(?![\s%:;()\[\]{}])(?:([^\s;"]+)|"((?:\^.|[^"^]+)*)")/;
	static final email = ~/^[\w\.]+@[\w\.]+/; // not perfect
	static final url = ~/^[a-zA-Z_]+:[^\s]+/; // very lazy for now
	static final char = ~/^#"(\^(?:[A-Z\[\]\\_@\-\/~"^]|\((?:[A-F\d]+|null|back|tab|line|page|esc|del)\))|.)"/i;
	static final issue = ~/^#(?!["\/()\[\]{}:;@\s])([^"\/()\[\]{}:;@\s]+)/;
	static final specialWord = ~/^(%+)(?=[\s()\[\]<>:]|$)/;
	static final time = ~/^([+-]?\d+):(\d+)(?::(\d+(?:\.\d+)?))?/;
	static final pair = ~/^([+-]?\d+)[xX]([+-]?\d+)/;
	static final tuple = ~/^(\d+)\.(\d+)\.(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?/;
	static final tag = ~/^<([^-=>\[\](){}l^"\s](?:"[^"]*"|'[^']*'|[^>])*)>/;
	static final ref = ~/^@([^#$',=>@\\^"();<\[\]{}\s]*)/;
	static final refinement = ~/^\/([^\/\\^,\[\](){}"#$%@:;\s]+)/;
	static final beginParen = "(";
	static final beginBlock = "[";
	static final beginMultiString = "{";
	static final beginMap = "#(";
	static final beginConstruct = "#[";
	static final beginBinary = ~/^(2|16|64)?#\{/;
	static final beginRawString = ~/^(%+)\{/;
	static final comment = ~/^;.*$/m;
	
	static final div = ~/^\/\/?(?=[\s()\[\]]|$)/;
	static final getDiv = ~/^:(\/\/?)/;
	static final litDiv = ~/^'(\/\/?)/;
	static final setDiv = ~/^(\/\/?):/;
}
