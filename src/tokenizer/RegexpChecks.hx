package tokenizer;

class RegexpChecks {
	public static final word = ~/^(?:[a-zA-Z_*=&|!?~`^]|(?:\.|[+-]\.?)(?!\d))/;
	public static final hexa = ~/^([A-F\d]{2,})h/;
	public static final integer = ~/^[+-]?\d+(?![\.xX]|#\{)/;
	public static final float = ~/^[+-]?(?:\d*\.\d+(?![\.\d])|\d+\.(?!\d+\.))/;
	public static final money = ~/^[+-]?[a-zA-Z]{0,3}\$\d/;
	public static final string = '"';
	public static final file = ~/^%(?![\s%:;()\[\]{}])/;
	public static final email = ~/^[\w\.]+@/; // not perfect
	public static final url = ~/^[a-zA-Z_]+:[^\s]/; // very lazy for now
	public static final char = '#"';
	public static final issue = ~/^#(?!["\/()\[\]{}:;@\s])/;
	public static final specialWord = ~/^(?:<[<=>]|>>>|>[>=]|[%<](?=[\s()\[\]<>:]|$)|>)/;
	public static final time = ~/^[+-]?\d+:\d/;
	public static final pair = ~/^[+-]?\d+[xX]/;
	public static final tuple = ~/^(?:\d+\.){2}/;
	public static final tag = ~/^<[^=><\[\](){}l^"\s](?:"[^"]*"|'[^']*'|[^>"']+)*/;
	public static final ref = "@";
	public static final refinement = "/";
	public static final date = ~/^\d+[\/\-T]/;
	public static final paren = "(";
	public static final block = "[";
	public static final multiString = "{";
	public static final map = "#(";
	public static final construct = "#[";
	public static final binary = ~/^(?:2|16|64)?#\{/;
	public static final rawString = ~/^%+\{/;
}
