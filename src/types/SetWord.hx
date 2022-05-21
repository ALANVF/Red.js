package types;

import types.base._Word;
import types.base.Symbol;
import types.base.Context;

class SetWord extends _Word {
	function copyWith(symbol: Symbol): SetWord {
		return new SetWord(symbol);
	}

	function copyIn(context: Context, index: Int): SetWord {
		return new SetWord(symbol, context, index);
	}

	function copyFrom(word: _Word): SetWord {
		return new SetWord(word.symbol, word.context, word.index);
	}
}