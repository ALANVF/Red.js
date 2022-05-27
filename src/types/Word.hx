package types;

import types.base._Word;
import types.base._AnyWord;
import types.base.Symbol;
import types.base.Context;

class Word extends _AnyWord {
	public function copyWith(symbol: Symbol): Word {
		return new Word(symbol);
	}

	function copyIn(context: Context, index: Int): Word {
		return new Word(symbol, context, index);
	}

	function copyFrom(word: _Word): Word {
		return new Word(word.symbol, word.context, word.index);
	}
}