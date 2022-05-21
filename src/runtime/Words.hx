package runtime;

import types.base.Symbol;

@:publicFields
class Words {
	static var SELF: Symbol;

	static function build() {
		SELF = Symbol.make("self");
		types.base.Context.GLOBAL.addSymbol(SELF);
	}
}