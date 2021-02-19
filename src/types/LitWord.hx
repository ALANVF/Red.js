package types;

using util.NullTools;

import types.base.Symbol;
import types.base.Context;

class LitWord extends Symbol {
	override function copyWith(?context: Context, ?offset: Int): LitWord {
		return new LitWord(this.name, context != null ? context : this.context, offset);
	}
}