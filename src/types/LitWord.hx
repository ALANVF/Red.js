package types;

import types.base.Symbol;
import types.base.Context;

class LitWord extends Symbol {
	function copyWith(?context: Context, ?offset: Int): LitWord {
		return new LitWord(this.name, context != null ? context : this.context, offset);
	}
}