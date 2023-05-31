package runtime;

import types.base.Symbol;
import types.base.Context;

@:publicFields
class Words {
	static var SELF: Symbol;
	static var LOCAL: Symbol;
	static var HOUR: Symbol;
	static var MINUTE: Symbol;
	static var SECOND: Symbol;

	static function build() {
		Context.GLOBAL.addSymbol(SELF = Symbol.make("self"));
		Context.GLOBAL.addSymbol(LOCAL = Symbol.make("local"));
		Context.GLOBAL.addSymbol(HOUR = Symbol.make("hour"));
		Context.GLOBAL.addSymbol(MINUTE = Symbol.make("minute"));
		Context.GLOBAL.addSymbol(SECOND = Symbol.make("second"));
	}
}