package types;

using util.NullTools;

import types.base.Symbol;
import types.base.Context;

class GetWord extends Symbol {
	override function copyWith(?context: Context, ?offset: Int): GetWord {
		return new GetWord(this.name, context != null ? context : this.context, offset);
	}
}