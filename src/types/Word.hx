package types;

import types.base.Symbol;
import types.base.Context;

class Word extends Symbol {
	// Required due to an obscure bug (that's probably caused by the build macro)
	override public function new(name: std.String, ?context: Context, ?offset: Int) super(name, context, offset);

	public function copyWith(?context: Context, ?offset: Int): Word {
		return new Word(this.name, context != null ? context : this.context, offset);
	}
}