package types;

import types.base._Word;
import types.base._AnyWord;
import types.base.Symbol;
import types.base.Context;

class GetWord extends _AnyWord {
	function copyWith(symbol: Symbol): GetWord {
		return new GetWord(symbol);
	}

	function copyIn(context: Context, index: Int): GetWord {
		return new GetWord(symbol, context, index);
	}

	function copyFrom(word: _Word): GetWord {
		return new GetWord(word.symbol, word.context, word.index);
	}
}