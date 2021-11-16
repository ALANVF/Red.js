package types;

import types.base.Symbol;
import types.base.Context;

class SetWord extends Symbol {
	function copyWith(?context: Context, ?offset: Int): SetWord {
		return new SetWord(this.name, context != null ? context : this.context, offset);
	}
}