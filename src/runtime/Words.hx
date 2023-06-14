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
	static var X: Symbol;
	static var Y: Symbol;
	static var DASH: Symbol;
	static var NOT: Symbol;
	static var SPEC: Symbol;
	static var BODY: Symbol;
	static var WORDS: Symbol;
	static var CHANGED: Symbol;
	static var CLASS: Symbol;
	static var VALUES: Symbol;
	static var OWNER: Symbol;

	static function build() {
		Context.GLOBAL.addSymbol(SELF = Symbol.make("self"));
		Context.GLOBAL.addSymbol(LOCAL = Symbol.make("local"));
		Context.GLOBAL.addSymbol(HOUR = Symbol.make("hour"));
		Context.GLOBAL.addSymbol(MINUTE = Symbol.make("minute"));
		Context.GLOBAL.addSymbol(SECOND = Symbol.make("second"));
		Context.GLOBAL.addSymbol(X = Symbol.make("x"));
		Context.GLOBAL.addSymbol(Y = Symbol.make("y"));
		Context.GLOBAL.addSymbol(DASH = Symbol.make("-"));
		Context.GLOBAL.addSymbol(NOT = Symbol.make("not"));
		Context.GLOBAL.addSymbol(SPEC = Symbol.make("spec"));
		Context.GLOBAL.addSymbol(BODY = Symbol.make("body"));
		Context.GLOBAL.addSymbol(WORDS = Symbol.make("words"));
		Context.GLOBAL.addSymbol(CHANGED = Symbol.make("changed"));
		Context.GLOBAL.addSymbol(CLASS = Symbol.make("class"));
		Context.GLOBAL.addSymbol(VALUES = Symbol.make("values"));
		Context.GLOBAL.addSymbol(OWNER = Symbol.make("owner"));
	}
}