package tokenizer;

class Regexps {
	public static final word = ~/^(?:[a-zA-Z_*=&|!?~`^]|(?:\.|[+-]\.?)(?!\d))(?:[\w+\-*=>&|!?~`\.'^]|<(?!<))*/;
	public static final hexa = ~/^([A-F\d]{2,})h/;
	public static final integer = ~/^[+-]?\d+(?![\.xX]|#\{)/;
	public static final float = ~/^[+-]?(?:\d*\.\d+(?!\.)|\d+\.)/;
	public static final money = ~/^([+-]?)([a-zA-Z]{0,3})\$(\d+(?:\.\d+)?)/;
	public static final string = ~/^"((?:\^.|[^"^]+)*)"/;
	public static final file = ~/^%(?![\s%:;()\[\]{}])(?:([^\s;"]+)|"((?:\^.|[^"^]+)*)")/;
	public static final email = ~/^[\w\.]+@[\w\.]+/; // not perfect
	public static final url = ~/^[a-zA-Z_]+:[^\s]+/; // very lazy for now
	public static final char = ~/^#"(\^(?:[A-Z\[\]\\_@\-\/~"^]|\((?:[A-F\d]+|null|back|tab|line|page|esc|del)\))|.)"/i;
	public static final issue = ~/^#(?!["\/()\[\]{}:;@\s])([^"\/()\[\]{}:;@\s]+)/;
	public static final specialWord = ~/^<[<=>]|>>>|>[>=]|[%<](?=[\s()\[\]<>:]|$)|>/;
	public static final time = ~/^([+-]?\d+):(\d+)(?::(\d+(?:\.\d+)?))?/;
	public static final pair = ~/^([+-]?\d+)[xX]([+-]?\d+)/;
	public static final tuple = ~/^(\d+)\.(\d+)\.(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?/;
	public static final tag = ~/^<([^=><\[\](){}l^"\s](?:"[^"]*"|'[^']*'|[^>])*)>/;
	public static final ref = ~/^@([^#$',=>@\\^"();<\[\]{}]*)/;
	public static final refinement = ~/^\/([^\/\\^,\[\](){}"#$%@:;]+)/;
	public static final beginParen = "(";
	public static final beginBlock = "[";
	public static final beginMultiString = "{";
	public static final beginMap = "#(";
	public static final beginConstruct = "#[";
	public static final beginBinary = ~/^(2|16|64)?#\{/;
	public static final beginRawString = ~/^(%+)\{/;
	public static final comment = ~/^;.*$/m;
	
	public static final div = ~/^\/\/?(?=[\s()\[\]]|$)/;
	public static final getDiv = ~/^:(\/\/?)/;
	public static final litDiv = ~/^'(\/\/?)/;
	public static final setDiv = ~/^(\/\/?):/;
}
