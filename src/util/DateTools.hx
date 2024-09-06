package util;

@:publicFields
class DateTools {
	static inline function asInt(date: Date): Int {
		#if js
		return js.Syntax.code("+{0}", date);
		#else
		return null;
		#end
	}

	static inline function copy(date: Date): Date {
		#if js
		return js.Syntax.code("new Date({0})", date);
		#else
		return null;
		#end
	}

	static function getYearday(date: Date): Int {
		#if js
		final diff = asInt(date) - asInt(cast new js.lib.Date(date.getFullYear(), 0, 1));
		return Std.int(diff / 86400000) + 1;
		#else
		return null;
		#end
	}

	#if js
	static inline function _setFullYear(self: js.lib.Date, y: Int, m: Int, d: Int)
		(untyped self).setFullYear(y, m, d);
	static inline function _setUTCFullYear(self: js.lib.Date, y: Int, m: Int, d: Int)
		(untyped self).setUTCFullYear(y, m, d);

	#else
	static inline function _setUTCFullYear(self: Date, y: Int, m: Int, d: Int) {}
	#end

	@:noUsing
	static function weekToDate(year: Int, week: Int): Date {
		#if js
		week -= 1;
		
		final date = new js.lib.Date(year, 0, week * 7);
		final day = date.getDay();
		
		if(day != 1) {
			date._setUTCFullYear(year, 0, (week * 7) + ((day < 4) ? 1 - day : (6 - day) + 2));
		}
		
		return cast date;
		#else
		return null;
		#end
	}
}