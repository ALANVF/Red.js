package types.base;

abstract class _Word extends Value {
	public var context: Context;
	public var symbol: Symbol;
	public var index: Int;

	public function new(symbol: Symbol, ?context: Context, ?index: Int) {
		this.symbol = symbol;
		Util._andOr(context, ctx => {
			this.context = ctx;
			this.index = Util._or(index, ctx.addSymbol(symbol));
		}, {
			this.context = Context.GLOBAL;
			this.index = Context.GLOBAL.addWord(this);
		});
	}

	public abstract function copyWith(symbol: Symbol): _Word;

	public abstract function copyIn(context: Context, index: Int): _Word;

	public abstract function copyFrom(word: _Word): _Word;

	public function get(optional = false) {
		final value = context.getWord(this);
		if(value == types.Unset.UNSET && !optional) {
			throw 'Word `${symbol.name}` doesn\'t exist!';
		} else {
			return value;
		}
	}

	public function set(value: Value) {
		context.setWord(this, value);
	}

	public function equalsString(str: std.String, ignoreCase = true) {
		return symbol.equalsString(str, ignoreCase);
	}

	public function equalsSymbol(sym: Symbol, ignoreCase = true) {
		return symbol.equalsSymbol(sym, ignoreCase);
	}

	public inline function equalsWord(word: _Word) {
		return symbol.equalsSymbol(word.symbol);
	}
}