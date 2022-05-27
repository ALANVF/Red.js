package runtime;

import types.base.Symbol;
import types.base.Context;

@:publicFields
class Words {
	static var SELF: Symbol;
	static var LOCAL: Symbol;

	static function build() {
		Context.GLOBAL.addSymbol(SELF = Symbol.make("self"));
		Context.GLOBAL.addSymbol(LOCAL = Symbol.make("local"));
	}
}