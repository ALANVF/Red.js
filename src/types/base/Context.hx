package types.base;

import util.Set;
import haxe.extern.EitherType;

class Context /*extends Value*/ {
	public static var GLOBAL: Context =
		#if macro new Context()
		// Can't rearrange the f***ing global statics
		#else js.Syntax.code("({0}.TABLE = new Map(), {1})", Symbol, new Context()) #end
	;

	public var symbols: Array<_Word>;
	public var values: Array<Value>;
	public var value: Null<#if macro Any #else EitherType<types.Object, types.Function> #end> = null;

	public function new(?symbols: Array<_Word>, ?values: Array<Value>) {
		if(symbols != null && values != null) {
			this.symbols = [for(i in 0...symbols.length) symbols[i].copyIn(this, i)];
			this.values = values.copy();
		} else {
			this.symbols = [];
			this.values = [];
		}
	}

	public function offsetOf(word: std.String, ignoreCase: Bool = true) {
		return if(ignoreCase) {
			this.symbols.findIndex(w -> w.equalsString(word));
		} else {
			this.symbols.findIndex(w -> w.symbol.name == word);
		}
	}

	public function offsetOfSymbol(sym: Symbol, ignoreCase: Bool = true) {
		return this.symbols.findIndex(w -> w.equalsSymbol(sym, ignoreCase));
	}

	public function get(word: std.String, ignoreCase: Bool = true) {
		switch this.offsetOf(word, ignoreCase) {
			case -1:
				throw 'Word `$word` doesn\'t exist!';
			case index:
				return this.values[index];
		}
	}

	public function getWord(word: _Word): Value {
	#if !macro
		if(word.symbol == runtime.Words.SELF && word.index == -1 && this.value != null && this.value is types.Object) {
			return (this.value : types.Object);
		}
	#end

		if(word.index == -1) {
			throw 'Word `${word.symbol.name} doesn\'t exist!';
		}

		return this.values[word.index];
	}

	public inline function getOffset(offset: Int) {
		return this.values[offset];
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

	public inline function setOffset(offset: Int, value: Value) {
		return this.values[offset] = value;
	}
	
	public function add(word: std.String, value: Value, ignoreCase = true) {
		if(this.contains(word, ignoreCase)) {
			throw 'Word `$word` already exists!';
		} else {
			final sym = new types.Word(Symbol.make(word), this, this.symbols.length);
			this.symbols.push(sym);
			this.values[sym.index] = value;
			return sym;
		}
	};

	public function addSymbol(symbol: Symbol) {
		final index = findOrStore(symbol);
		if(index != -1) return index;
		return this.values.push(Unset.UNSET) - 1;
	}

	public function addOrSet(word: std.String, value: Value, ignoreCase: Bool = true): _Word {
		switch this.offsetOf(word, ignoreCase) {
			case -1:
				final sym = new types.Word(Symbol.make(word), this, this.symbols.length);
				this.symbols.push(sym);
				this.values.push(value);
				return sym;
			case index:
				this.values[index] = value;
				return this.symbols[index];
		}
	}

	public function contains(word: std.String, ignoreCase: Bool = true) {
		return this.offsetOf(word, ignoreCase) != -1;
	}

	public function containsSymbol(sym: Symbol) {
		return this.symbols.some(s -> s.symbol == sym);
	}

#if !macro
	public function collectSetWords(block: types.Block) {
		final origSize = symbols.length;
		
		for(value in block) Util._match(value,
			at(word is types.SetWord) => {
				this.addWord(word);
			},
			_ => {}
		);

		return origSize < symbols.length;
	}
#end

	private function findOrStore(symbol: types.base.Symbol, ignoreCase = true) {
		final index = this.offsetOfSymbol(symbol, ignoreCase);
		if(index == -1) {
			final word: types.Word = #if macro untyped null #else js.Syntax.code("new {0}({1})", types.Word, symbol) #end;
			final newIndex = this.symbols.push(word) - 1;
			word.context = this;
			word.index = newIndex;
			return -1;
		} else {
			return index;
		}
	}

	public function addWord(word: types.base._Word, ignoreCase = true) {
		final index = this.offsetOfSymbol(word.symbol, ignoreCase);
		if(index == -1) {
			final newIndex = this.symbols.push(word) - 1;
			word.context = this;
			word.index = newIndex;
			this.values.push(Unset.UNSET);
			return newIndex;
		} else {
			return index;
		}
	}

	public function addOrSetWord(word: types.base._Word, value: Value, ignoreCase = true) {
		this.values[this.addWord(word, ignoreCase)] = value;
	}

	public inline function setWord(word: types.base._Word, value: Value, ignoreCase = true) {
		// todo?
		this.addOrSetWord(word, value, ignoreCase);
	}

	public function bindWord(word: types.base._Word) {
		final index = this.offsetOfSymbol(word.symbol);
		if(index != -1) {
			word.context = this;
			word.index = index;
		}

		return index;
	}

#if !macro
	public function bind(block: types.base._SeriesOf<Value>, hasSelf: Bool, cache: Set<Value> = /*BAD*/untyped null) {
		if(cache == null) {
			cache = new Set();
		} else {
			if(cache.has(block)) {
				return;
			} else {
				cache.add(block);
			}
		}
		
		final values = block.values;
		for(i in block.index...block.absLength) {
			Util._match(values[i],
				at(word is types.base._AnyWord | word is types.Refinement) => {
					if(hasSelf && word is types.Word && word.symbol == runtime.Words.SELF) {
						values[i] = word.copyIn(this, -1);
					} else {
						word = word.copyFrom(word);
						this.bindWord(word);
						values[i] = word;
					}
				},
				at(blk is types.base._Block | blk is types.base._Path) => {
					this.bind(blk, hasSelf, cache);
				},
				_ => {}
			);
		}

		cache.remove(block);

		return;
	}
#end
}