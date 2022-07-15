package types.base;

class Symbol {
	public static var TABLE(default, never): Dict<std.String, Symbol>;
	public static var INDEXES(default, never): Dict<std.String, Int>;
	public static var MAX_INDEX(default, never): Int;

	public final name: std.String;

	private function new(name: std.String) {
		this.name = name;
	}

	public static function make(name: std.String): Symbol {
		//return TABLE[name] ?? TABLE[name] = new Symbol(name);
	#if macro
		return untyped null;
	#else
		js.Syntax.code("let tmp");
		return js.Syntax.code("{0}.get({3}) ?? ({1}.set({3}, {2}++), {0}.set({3}, tmp = new {4}({3})), tmp)",
								TABLE, INDEXES, MAX_INDEX, name, Symbol);
	#end
	}

	public function equalsString(str: std.String, ignoreCase = true) {
		return ignoreCase
			? this.name.toLowerCase() == str.toLowerCase()
			: this.name == str;
	}

	public function equalsSymbol(sym: Symbol, ignoreCase = true) {
		return ignoreCase
			? this.name.toLowerCase() == sym.name.toLowerCase()
			: this == sym;
	}

	public var index(get, never): Int;
	inline function get_index(): Int {
		return INDEXES[name];
	}
}