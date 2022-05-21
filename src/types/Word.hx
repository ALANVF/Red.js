package types;

import types.base._Word;
import types.base.Symbol;
import types.base.Context;

class Word extends _Word {
	// Required due to an obscure bug (that's probably caused by the build macro)
	//override public function new(name: std.String, ?context: Context, ?offset: Int) super(name, context, offset);

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