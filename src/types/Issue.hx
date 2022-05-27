package types;

import types.base._Word;
import types.base.Symbol;
import types.base.Context;

class Issue extends _Word {
	override public function new(symbol: Symbol, ?_: Context, ?_: Int) {
		super(symbol, Context.GLOBAL, -1);
	}

	function copyWith(symbol: Symbol): Issue {
		return new Issue(symbol);
	}
	
	function copyIn(context: Context, index: Int): Issue {
		return this;
	}

	function copyFrom(word: _Word): Issue {
		return new Issue(word.symbol);
	}
}