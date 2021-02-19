package types;

using util.NullTools;

import types.base.Symbol;
import types.base.Context;

class SetWord extends Symbol {
	override function copyWith(?context: Context, ?offset: Int): SetWord {
		return new SetWord(this.name, context != null ? context : this.context, offset);
	}
}