package types.base;

class Symbol {
	public static var TABLE(default, never): Dict<std.String, Symbol>;

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
		return js.Syntax.code("{0}.get({1}) ?? ({0}.set({1}, tmp = new {2}({1})), tmp)",
								TABLE, name, Symbol);
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
}