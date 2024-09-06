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
	static var Z: Symbol;
	static var DASH: Symbol;
	static var NOT: Symbol;
	static var SPEC: Symbol;
	static var BODY: Symbol;
	static var WORDS: Symbol;
	static var CHANGED: Symbol;
	static var CLASS: Symbol;
	static var VALUES: Symbol;
	static var OWNER: Symbol;
	static var AMOUNT: Symbol;
	static var CODE: Symbol;
	static var DATE: Symbol;
	static var YEAR: Symbol;
	static var MONTH: Symbol;
	static var DAY: Symbol;
	static var ZONE: Symbol;
	static var TIME: Symbol;
	static var WEEKDAY: Symbol;
	static var YEARDAY: Symbol;
	static var JULIAN: Symbol;
	static var TIMEZONE: Symbol;
	static var WEEK: Symbol;
	static var ISOWEEK: Symbol;

	static function build() {
		Context.GLOBAL.addSymbol(SELF = Symbol.make("self"));
		Context.GLOBAL.addSymbol(LOCAL = Symbol.make("local"));
		Context.GLOBAL.addSymbol(HOUR = Symbol.make("hour"));
		Context.GLOBAL.addSymbol(MINUTE = Symbol.make("minute"));
		Context.GLOBAL.addSymbol(SECOND = Symbol.make("second"));
		Context.GLOBAL.addSymbol(X = Symbol.make("x"));
		Context.GLOBAL.addSymbol(Y = Symbol.make("y"));
		Context.GLOBAL.addSymbol(Z = Symbol.make("z"));
		Context.GLOBAL.addSymbol(DASH = Symbol.make("-"));
		Context.GLOBAL.addSymbol(NOT = Symbol.make("not"));
		Context.GLOBAL.addSymbol(SPEC = Symbol.make("spec"));
		Context.GLOBAL.addSymbol(BODY = Symbol.make("body"));
		Context.GLOBAL.addSymbol(WORDS = Symbol.make("words"));
		Context.GLOBAL.addSymbol(CHANGED = Symbol.make("changed"));
		Context.GLOBAL.addSymbol(CLASS = Symbol.make("class"));
		Context.GLOBAL.addSymbol(VALUES = Symbol.make("values"));
		Context.GLOBAL.addSymbol(OWNER = Symbol.make("owner"));
		Context.GLOBAL.addSymbol(AMOUNT = Symbol.make("amount"));
		Context.GLOBAL.addSymbol(CODE = Symbol.make("code"));
		Context.GLOBAL.addSymbol(DATE = Symbol.make("date"));
		Context.GLOBAL.addSymbol(YEAR = Symbol.make("year"));
		Context.GLOBAL.addSymbol(MONTH = Symbol.make("month"));
		Context.GLOBAL.addSymbol(DAY = Symbol.make("day"));
		Context.GLOBAL.addSymbol(ZONE = Symbol.make("zone"));
		Context.GLOBAL.addSymbol(TIME = Symbol.make("time"));
		Context.GLOBAL.addSymbol(WEEKDAY = Symbol.make("weekday"));
		Context.GLOBAL.addSymbol(YEARDAY = Symbol.make("yearday"));
		Context.GLOBAL.addSymbol(JULIAN = Symbol.make("julian"));
		Context.GLOBAL.addSymbol(TIMEZONE = Symbol.make("timezone"));
		Context.GLOBAL.addSymbol(WEEK = Symbol.make("week"));
		Context.GLOBAL.addSymbol(ISOWEEK = Symbol.make("isoweek"));

		@:privateAccess runtime.actions.datatypes.DateActions.ACCESSORS = [
			cast null, // to offset index by 1
			Words.DATE,
			Words.YEAR,
			Words.MONTH,
			Words.DAY,
			Words.ZONE,
			Words.TIME,
			Words.HOUR,
			Words.MINUTE,
			Words.SECOND,
			Words.WEEKDAY,
			Words.YEARDAY,
			Words.JULIAN,
			Words.TIMEZONE,
			Words.WEEK,
			Words.ISOWEEK
		];
	}
}