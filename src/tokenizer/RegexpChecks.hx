package tokenizer;

@:publicFields
class RegexpChecks {
	static final word = ~/^(?:[a-zA-Z_*=>&|!?~`^]|<+(?=[-:=>\[\](){}l^"\s]|$)|(?:\.|[+-]\.?)(?!\d))/;
	static final hexa = ~/^([A-F\d]{2,})h/;
	static final integer = ~/^[+-]?\d+\b(?!\.|#\{)/;
	static final specialFloat = ~/^[+-]?1\.#/;
	static final float = ~/^[+-]?(?:\d*\.\d+(?![\.\d])|\d+\.(?!\d+\.)|\d+[eE][+-]?\d+)/;
	static final money = ~/^[+-]?[a-zA-Z]{0,3}\$\d/;
	static final string = '"';
	static final file = ~/^%(?![\s%:;()\[\]{}])/;
	static final email = ~/^[\w\.]+@/; // not perfect
	static final url = ~/^[a-zA-Z_]+:[^\s]/; // very lazy for now
	static final char = '#"';
	static final issue = ~/^#(?!["\/()\[\]{}:;@\s])/;
	static final specialWord = ~/^%+(?=[\s()\[\]<>:]|$)/;
	static final time = ~/^[+-]?\d+:\d/;
	static final pair = ~/^[+-]?\d+[xX]/;
	static final tuple = ~/^(?:\d+\.){2}/;
	static final point = ~/^\(\d+(?:\.(?:#Inf|#NaN|\d+(?:[eE][+-]?\d+)?)|e[+-]?\d+)?\s*,\s/;
	static final tag = ~/^<[^-=>\[\](){}l^"\s](?:"[^"]*"|'[^']*'|[^>"']+)*/;
	static final ref = "@";
	static final refinement = "/";
	static final date = ~/^\d+[\/\-T]/;
	static final paren = "(";
	static final block = "[";
	static final multiString = "{";
	static final map = "#(";
	static final construct = "#[";
	static final binary = ~/^(?:2|16|64)?#\{/;
	static final rawString = ~/^%+\{/;
}
