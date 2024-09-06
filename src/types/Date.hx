package types;

import types.base.IGetPath;
import haxe.ds.Option;
import haxe.ds.Either;

using DateTools;

@:publicFields
class Date extends Value implements IGetPath {
	static final ACCESSORS = [
		"date", "year", "month", "day", "zone",
		"time", "hour", "minute", "second", "weekday",
		"yearday", "julian", "timezone", "week", "isoweek"
	];

	var date: std.Date;
	var zone: Time;

	function new(date: std.Date, ?zone: Time) {
		this.date = date;
		this.zone = zone ?? {
			final offset = date.getTimezoneOffset();
			new Time(offset * 60);
		};
	}

	function getDate() {
		return new Date(new std.Date(getYear(), date.getMonth(), getDay(), 0, 0, 0));
	}

	inline function getYear() return date.getFullYear();

	inline function getMonth() return date.getMonth() + 1;

	inline function getDay() return date.getDate();
	
	inline function getTime() return date.getTime() / 1000;

	inline function getHour() return date.getHours();

	inline function getMinute() return date.getMinutes();

	/*function getSecond() {
		return Std.int((date.getTime() % 60000) / 1000);
	}*/

	inline function getSecond() return date.getSeconds();

	inline function getMillisecond() {
		return (cast date : js.lib.Date).getMilliseconds();
	}

	inline function setDate(d: std.Date) {
		(cast date : js.lib.Date).setFullYear(d.getFullYear());
		(cast date : js.lib.Date).setMonth(d.getMonth());
		(cast date : js.lib.Date).setDate(d.getDate());
	}

	inline function setYear(y: Int) (cast date : js.lib.Date).setFullYear(y);

	inline function setMonth(m: Int) (cast date : js.lib.Date).setMonth(m - 1);

	inline function setDay(d: Int) (cast date : js.lib.Date).setDate(d);
	
	inline function setTime(t: Int) (cast date : js.lib.Date).setTime(t * 1000);

	inline function setHour(h: Int) (cast date : js.lib.Date).setHours(h);

	inline function setMinute(m: Int) (cast date : js.lib.Date).setMinutes(m);

	inline function setSecond(s: Int) (cast date : js.lib.Date).setSeconds(s);

	inline function setMillisecond(ms: Int) (cast date : js.lib.Date).setMilliseconds(ms);

	// timezone

	/*inline function getYearday() {
		return toDays() - getJan1st() + 1;
	}*/

	inline function getWeekday() return date.getDay() + 1;

	// week

	// isoweek

	function getPath(access: Value, ?ignoreCase = true) {
		return Util._match(access,
			at({int: i} is Integer) => Some(Left(i)),
			at((_.symbol.name.toLowerCase() => n) is Word, when(ignoreCase && ACCESSORS.contains(n))) => Some(Right(n)),
			at({symbol: {name: n}} is Word, when(!ignoreCase && ACCESSORS.contains(n))) => Some(Right(n)),
			_ => None
		).flatMap(v -> (switch v {
			case Left(1) | Right("date"): Some(getDate());
			case Left(2) | Right("year"): Some(new Integer(getYear()));
			case Left(3) | Right("month"): Some(new Integer(getMonth()));
			case Left(4) | Right("day"): Some(new Integer(getDay()));
			case Left(5) | Right("zone"): Some(zone);
			case Left(6) | Right("time"): Some(new Time(getTime()));
			case Left(7) | Right("hour"): Some(new Integer(getHour()));
			case Left(8) | Right("minute"): Some(new Integer(getMinute()));
			case Left(9) | Right("second"): Some({
				final sec = getSecond();
				if(sec % 1 == 0) {
					new Integer(cast sec);
				} else {
					new types.Float(sec);
				}
			});
			case Left(10) | Right("weekday"): Some(new Integer(getWeekday()));
			case Left(11) | Right("yearday" | "julian"): Some(null);
			case Left(12) | Right("timezone"): Some(null);
			case Left(13) | Right("week"): Some(null);
			case Left(14) | Right("isoweek"): Some(null);
			default: None;
		} : Option<Value>));
	}
}