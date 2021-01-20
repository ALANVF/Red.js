package types;

import types.base.IGetPath;
import haxe.ds.Option;
import haxe.ds.Either;

using DateTools;

class Date extends Value implements IGetPath {
	public static final ACCESSORS = [
		"date", "year", "month", "day", "zone",
		"time", "hour", "minute", "second", "weekday",
		"yearday", "julian", "timezone", "week", "isoweek"
	];

	public var date: std.Date;
	public var zone: Time;

	public function new(date: std.Date) {
		this.date = date;
	}

	public function getDate() {
		return new Date(new std.Date(getYear(), getMonth(), getDay(), 0, 0, 0));
	}

	public inline function getYear() return date.getFullYear();

	public inline function getMonth() return date.getMonth() + 1;

	public inline function getDay() return date.getDate();
	
	// time

	public inline function getHour() return date.getHours();

	public inline function getMinute() return date.getMinutes();

	public function getSecond() {
		return (date.getTime() % 60000) / 1000;
	}

	// timezone

	// yearday

	public inline function getWeekday() return date.getDay() + 1;

	// week

	// isoweek

	public function getPath(access: Value, ?ignoreCase = true) {
		return (switch access.KIND {
			case KInteger(_.int => i): Some(Left(i));
			case KWord(_.name.toLowerCase() => n) if(ignoreCase && ACCESSORS.contains(n)): Some(Right(n));
			case KWord(_.name => n) if(!ignoreCase && ACCESSORS.contains(n)): Some(Right(n));
			default: None;
		}).flatMap(v -> (switch v {
			case Left(1) | Right("date"): Some(getDate());
			case Left(2) | Right("year"): Some(new Integer(getYear()));
			case Left(3) | Right("month"): Some(new Integer(getMonth()));
			case Left(4) | Right("day"): Some(new Integer(getDay()));
			case Left(5) | Right("zone"): Some(zone);
			case Left(6) | Right("time"): Some(new Time(getHour(), getMinute(), getSecond()));
			case Left(7) | Right("hour"): Some(new Integer(getHour()));
			case Left(8) | Right("minute"): Some(new Integer(getMinute()));
			case Left(9) | Right("second"): Some({
				final sec = getSecond();
				if(sec % 1 == 0) {
					new Integer(Std.int(sec));
				} else {
					new types.Float(sec);
				}
			});
			case Left(10) | Right("weekday"): throw "NYI!";
			case Left(11) | Right("yearday" | "julian"): throw "NYI!";
			case Left(12) | Right("timezone"): throw "NYI!";
			case Left(13) | Right("week"): throw "NYI!";
			case Left(14) | Right("isoweek"): throw "NYI!";
			default: None;
		} : Option<Value>));
	}
}