package types.base;

class Context extends Value {
	public static var GLOBAL = new Context();

	public var symbols: Array<Symbol>;
	public var values: Array<Value>;

	public function new(?symbols: Array<Symbol>, ?values: Array<Value>) {
		if(symbols != null && values != null) {
			this.symbols = [for(i in 0...symbols.length) symbols[i].copyWith(this, i)];
			this.values = values.copy();
		} else {
			this.symbols = [];
			this.values = [];
		}
	}

	public function offsetOf(word: std.String, ignoreCase: Bool = true) {
		return if(ignoreCase) {
			this.symbols.map(w -> w.equalsString(word)).indexOf(true);
		} else {
			this.symbols.map(w -> w.name).indexOf(word);
		}
	}

	public function get(word: std.String, ignoreCase: Bool = true) {
		switch this.offsetOf(word, ignoreCase) {
			case -1:
				throw 'Word `$word` doesn\'t exist!';
			case index:
				return this.values[index];
		}
	}

	public function getSymbol(sym: Symbol) {
		if(this.containsSymbol(sym)) {
			return this.values[sym.offset];
		} else {
			throw 'Word `${sym.name}` doesn\'t exist!';
		}
	}

	public function set(word: std.String, value: Value, ignoreCase: Bool = true) {
		switch this.offsetOf(word, ignoreCase) {
			case -1:
				throw 'Word `$word` doesn\'t exist!';
			case index:
				this.values[index] = value;
				return value;
		}
	}

	public function setSymbol(sym: Symbol, value: Value) {
		if(this.containsSymbol(sym)) {
			this.values[sym.offset] = value;
			return value;
		} else {
			throw 'Word `${sym.name}` doesn\'t exist!';
		}
	}
	
	public function add(word: std.String, value: Value, ignoreCase: Bool = true) {
		if(this.contains(word)) {
			throw 'Word `$word` already exists!';
		} else {
			final sym = new Word(word, this, this.symbols.length);
			this.symbols.push(sym);
			this.values.push(value);
			return sym;
		}
	};

	public function addSymbol(word: Symbol, copy = false) {
		switch this.offsetOf(word.name) {
			case -1:
				final sym = if(copy) {
					word.copyWith(this, this.symbols.length);
				} else {
					word.context = this;
					word.offset = this.symbols.length;
					word;
				};
				this.symbols.push(sym);
				this.values.push(Unset.UNSET);
				return sym;
			case offset:
				word.context = this;
				word.offset = offset;
				return word;
		}
	}

	/*public function remove(word: String, ignoreCase: Bool = true) {
		switch this.offsetOf(word, ignoreCase) {
			case -1:
				throw 'Word `$word` doesn\'t exist!';
			case index:
				this.symbols.splice(index, 1);
				return this.values.splice(index, 1)[0];
		}
	}*/

	public function contains(word: std.String, ignoreCase: Bool = true) {
		return this.offsetOf(word, ignoreCase) != -1;
	}

	public function containsSymbol(sym: Symbol) {
		return sym.context == this;
	}
}

abstract _ContextHelper(Context) from Context to Context {
	@:arrayAccess
	public inline function getAt(word: std.String) {
		return this.get(word);
	}

	@:arrayAccess
	public inline function getSymbolAt(sym: Symbol) {
		return this.getSymbol(sym);
	}

	@:arrayAccess
	public inline function setAt(word: std.String, value: Value) {
		return this.set(word, value);
	}

	@:arrayAccess
	public inline function setSymbolAt(sym: Symbol, value: Value) {
		return this.setSymbol(sym, value);
	}
}