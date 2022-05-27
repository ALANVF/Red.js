package types;

import types.base._Word;
import types.base.Symbol;
import types.base.Context;

class Refinement extends _Word {
	function copyWith(symbol: Symbol): Refinement {
		return new Refinement(symbol);
	}
	
	function copyIn(context: Context, index: Int): Refinement {
		return new Refinement(symbol, context, index);
	}

	function copyFrom(word: _Word): Refinement {
		return new Refinement(word.symbol, word.context, word.index);
	}
}