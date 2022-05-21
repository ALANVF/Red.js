package types;

import types.base._Word;
import types.base.Symbol;
import types.base.Context;

class LitWord extends _Word {
	function copyWith(symbol: Symbol): LitWord {
		return new LitWord(symbol);
	}
	
	function copyIn(context: Context, index: Int): LitWord {
		return new LitWord(symbol, context, index);
	}

	function copyFrom(word: _Word): LitWord {
		return new LitWord(word.symbol, word.context, word.index);
	}
}