package runtime.actions.datatypes;

import types.base.MathOp;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Date;
import types.Time;
import types.Integer;
import types.String;
import types.Word;
import types.None;

import runtime.actions.datatypes.ValueActions.invalid;

class DateActions extends ValueActions<Date> {
	static final MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

	private static var ACCESSORS: Array<types.base.Symbol>; // initialized in Words.build

	static function getNamedIndex(w: Word) {
		final idx = ACCESSORS.indexOf(w.symbol);
		return idx > 11 ? idx - 1 : idx;
	}

	static function getField(d: Date, field: Int): Value {
		return field._match(
			at(1) => d.getDate(),
			at(2) => new Integer(d.getYear()),
			at(3) => new Integer(d.getMonth()),
			at(4) => new Integer(d.getDay()),
			at(5 | 12) => d.zone,
			at(6) => {
				final h = d.getHour();
				final m = d.getMinute();
				final s = d.getSecond();
				final ms = d.getMillisecond();
				if(h + m + s + ms == 0) None.NONE;
				else Time.fromHMS(h, m, ms == 0 ? s : s + ms/1000);
			},
			at(7) => new Integer(d.getHour()),
			at(8) => new Integer(d.getMinute()),
			at(9) => {
				final s = d.getSecond();
				final ms = d.getMillisecond();
				new types.Float(ms == 0 ? s : s + ms/1000);
			},
			at(10) => new Integer(d.getWeekday() - 1),
			at(11) => new Integer(getYearday(d.date)),
			at(13) => {
				final wd = (jan1stOf(d.date) + 3) % 7;
				final days = 7 - wd;
				var yd = getYearday(d.date);
				yd = if(yd <= days) 1 else ((yd + wd - 1) % 7) + 1;
				new Integer(yd);
			},
			at(14) => {
				Util.detuple(@var [wd, d1], w11of(d.date));
				final days = dateToDays(d.date);
				final w = if(days >= d1) {
					final y = 1 + d.getYear();
					final dt = d.date.copy();
					(cast dt : js.lib.Date).setFullYear(y);
					Util.detuple([wd, @var d2], w11of(dt));
					if(days < d2) Std.int((days - d1) / 7) + 1 else 1;
				} else {
					wd._match(
						at(1...4) => 1,
						at(5) => 53,
						at(6) => if(isLeapYear(d.getYear() - 1)) 53 else 52,
						at(7) => 52,
						_ => invalid()
					);
				}
				new Integer(w);
			},
			_ => invalid()
		);
	}

	// TODO: this is broken and idk why. it's literally copied from the main impl lol https://github.com/red/red/blob/master/runtime/datatypes/date.reds#L213
	static function daysToDate(days: Int, tz: Int, hasTime: Bool) {
		var f = 10000 * days;
		var y = Std.int((f + 14780) / 3652425);
		
		var dd = days - ((365 * y) + Std.int(y / 4) - Std.int(y / 100) + Std.int(y / 400));
		if(dd < 0) {
			y -= 1;
			dd = days - ((365 * y) + Std.int(y / 4) - Std.int(y / 100) + Std.int(y / 400));
		}

		final mi = Std.int(((100 * dd) + 52) / 3060);
		final m = ((mi + 2) % 12);// + 1;
		y += Std.int((mi + 2) / 12);
		var d = dd - Std.int(((mi * 306) + 5) / 10) + 1;
		d = (y << 17) | (m << 12) | (d << 7) | tz;
		return std.Date.fromTime(d & 0xFFFEFFFF | (hasTime.asInt() << 16));
	}

	// TODO: there's a chance this is also broken but I highly doubt it
	static function dateToDays(d: std.Date) {
		var y = d.getFullYear();
		var m = d.getMonth() + 1;
		var d = d.getDate();
		m = (m + 9) % 12;
		y -= Std.int(m / 10);
		return (365 * y) + Std.int(y / 4) - Std.int(y / 100) + Std.int(y / 400) + Std.int(((m * 306) + 5) / 10) + (d - 1);
	}

	static function isLeapYear(year: Int) {
		return (year & 3 == 0 && year % 100 != 0) || year % 400 == 0;
	}

	static function jan1stOf(d: std.Date) {
		d = d.copy();
		(cast d : js.lib.Date).setDate(1);
		(cast d : js.lib.Date).setMonth(0);
		return dateToDays(d);
	}

	static function getYearday(d: std.Date) {
		return dateToDays(d) - jan1stOf(d) + 1;
	}

	static function w11of(d: std.Date) {
		final days = jan1stOf(d);
		final wd = ((days + 2) % 7) + 1;
		final base = wd < 5 ? 1 : 8;
		return new Tuple2(
			wd,
			days + base - wd
		);
	}

	static function _create(spec: types.base._Block, isNorm: Bool) {
		var date: js.lib.Date;
		var zone: Null<Time> = null;

		var year = 0;
		var month = 0;
		var day = 0;
		var hours = 0;
		var minutes = 0;
		var seconds = 0;
		var zone = 0;
		var ftime = Time.ZERO;
		var zoneT = Time.ZERO;
		var secT = Time.ZERO;

		var cnt = 0;
		for(value in spec) {
			var i = 0;
			var t = Time.ZERO;
			final v = value._match(
				at(w is Word) => w.get(),
				_ => value
			);
			v._match(
				at({int: int} is Integer) => {
					i = int;
				},
				at({float: float} is types.Float) => {
					i = Std.int(float);
				},
				at(time is Time) => {
					if(cnt <= 3) throw "bad";
					t = time;
				},
				_ => throw "bad"
			);
			cnt._match(
				at(0) => { day = i; },
				at(1) => { month = i - 1; },
				at(2) => { year = i; },
				at(3) => { hours = i; ftime = t; },
				at(4) => { minutes = i; zoneT = t; },
				at(5) => { seconds = i; secT = t; },
				at(6) => { zone = i; zoneT = t; },
			);
			cnt++;
		}
		if((cnt < 3 && cnt > 7)     // # of args out of range
		|| (cnt == 4 && hours != 0) // time argument expected to be a time! value
		|| (cnt == 5 && hours != 0) // time argument expected to be a time! value
		) {
			throw "bad";
		}

		if(cnt == 5 || cnt == 7) {
			var i, mn;
			if((
				(cnt == 5 && minutes == 0)
				|| (cnt == 7 && zone == 0)
			)
			&& zoneT.float != 0.0
			) {
				i = zoneT.hours;
				mn = Std.int(zoneT.minutes / 15);
			} else {
				i = if(cnt == 5 && minutes != 0) minutes else zone;
				mn = 0;
			}
			if(cnt == 7 && zoneT.float == 0.0 && (zone > 15 || zone < -15)) {
				throw "bad";
			}
			final isNeg = if(i < 0) { i = -i; true; } else false;
			zone = ((i << 2) & 0x7F) | mn;
			if(isNeg) zone |= 0x40;
		}
		if(cnt == 6 || cnt == 7) {
			final t = (hours * 3600) + (minutes * 60);
			(untyped ftime).float = if(secT.float == 0.0) t + seconds else t + secT.float;
		}
		if(day >= 100 && day > year) Util.swap(day, year); // allow year to be first

		date = new js.lib.Date(year, month, day, hours, minutes, seconds);
		//date = cast daysToDate(day + dateToDays(cast date), 0, cnt > 3);
		
		if(!isNorm) {
			final h = ftime.hours;
			minutes = if(cnt == 4 || cnt == 5) ftime.minutes else date.getMinutes();
			if(year != date.getFullYear()
			|| month != date.getMonth()
			|| day != date.getDate()
			|| (ftime.float != 0.0 && (
				h < 0 || h > 23
				|| minutes != date.getMinutes()
			))
			|| (ftime.float == 0.0 && (
				hours != date.getHours()
				|| minutes != date.getMinutes()
			))
			) {
				throw "bad";
			}
		}
		
		return new Date(cast date, new Time(zone));
	}


	override function make(proto: Null<Date>, spec: Value) {
		//return _create(spec);
		return spec._match(
			at(b is types.base._Block) => _create(b, false),
			_ => throw "bad"
		);
	}

	override function to(proto: Null<Date>, spec: Value) {
		return spec._match(
			at(d is Date) => new Date(d.date.copy(), d.zone),
			at(b is types.base._Block) => _create(b, true),
			at(i is Integer) => {
				final int = i.int;
				var d = daysToDate(
					Std.int(int / 86400) + jan1stOf(std.Date.fromTime(1970 << 17)),
					0,
					true
				);
				(cast d : js.lib.Date).setTime(d.getTime() + (int % 86400));
				return new Date(d);
			},
			_ => invalid()
		);
	}

	override function form(value: Date, buffer: String, arg: Null<Int>, part: Int) {
		return mold(value, buffer, false, false, false, arg, part, 0);
	}

	override function mold(
		value: Date, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		var year = value.getYear();
		final sep = year < 0 ? '/'.code : '-'.code;

		var formed = value.getDay().toString();
		buffer.appendLiteral(formed);
		part -= formed.length;

		buffer.appendChar(sep);

		final month = MONTHS[value.getMonth() - 1];
		buffer.appendLiteral(month);

		buffer.appendChar(sep);

		if(year < 0) {
			year = -year;
			buffer.appendChar('-'.code);
		}
		formed = year.toString();
		part = if(year < 100) {
			buffer.appendChar('0'.code);
			if(year < 10) buffer.appendChar('0'.code);
			part - 5;
		} else {
			part - formed.length;
		};
		buffer.appendLiteral(formed);

		final hour = value.getHour();
		final minute = value.getMinute();
		final second = value.getSecond();
		final ms = value.getMillisecond();
		if(hour != 0 || minute != 0 || second != 0 || ms != 0) {
			buffer.appendChar('/'.code);

			formed = hour.toString();
			buffer.appendLiteral(formed);
			part -= formed.length;

			buffer.appendChar(':'.code);
			part--;

			if(minute < 10) {
				buffer.appendChar('0'.code);
				part--;
			}
			formed = minute.toString();
			buffer.appendLiteral(formed);
			part -= formed.length;

			buffer.appendChar(':'.code);
			part--;

			if(second < 10) {
				buffer.appendChar('0'.code);
				part--;
			}
			formed = second.toString();
			buffer.appendLiteral(formed);
			part -= formed.length;

			if(ms != 0) {
				buffer.appendChar('.'.code);
				formed = ms.toString();
				buffer.appendLiteral(formed);
				part -= formed.length + 1;
			}

			final zone = value.zone;
			if(zone.float != 0) {
				final sign = zone.float < 0 ? '-'.code : '+'.code;
				buffer.appendChar(sign);
				final hour = zone.hours;
				if(hour < 10) {
					buffer.appendChar('0'.code);
					part--;
				}
				formed = hour.toString();
				buffer.appendLiteral(formed);
				part -= formed.length + 1;

				buffer.appendChar(':'.code);
				final minute = zone.minutes;
				if(minute < 10) {
					buffer.appendChar('0'.code);
					part--;
				}
				formed = minute.toString();
				buffer.appendLiteral(formed);
				part -= formed.length + 1;
			}
		}
		return part;
	}

	override function evalPath(
		parent: Date, element: Value, value: Null<Value>,
		path: Null<types.base._Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	): Value {
		final idx = element._match(
			at(i is Integer) => i.int,
			at(w is Word) => getNamedIndex(w),
			_ => invalid()
		);
		if(idx < 1 || idx > 14) invalid();

		if(value != null) {
			final v = idx._match(
				at((2...4) | 7 | 8 | 10 | 11 | 13 | 14) => {
					value._match(
						at(i is Integer) => i.int,
						_ => invalid()
					);
				},
				_ => 0
			);
			final dt = parent;
			final d = dt.date;
			final hasTime = (dt.getHour() + dt.getMinute() + dt.getSecond() + dt.getMillisecond()) != 0;
			idx._match(
				at(1) => value._match(
					at(v is Date) => dt.setDate(v.date),
					_ => invalid()
				),
				at(2) => dt.setYear(v),
				at(3) => dt.setMonth(v),
				at(4) => dt.setDay(v),
				at(5 | 12) => value._match(
					at(v is Time) => dt.zone = v,
					_ => invalid()
				),
				at(6) => value._match(
					at(_ is None) => {
						dt.setHour(0);
						dt.setMinute(0);
						dt.setSecond(0);
						dt.setMillisecond(0);
					},
					at(v is Time) => {
						dt.setHour(v.hours);
						dt.setMinute(v.minutes);
						dt.setSecond(Std.int(v.seconds));
						dt.setMillisecond(Std.int((v.seconds - Std.int(v.seconds)) * 1000));
					},
					_ => invalid()
				),
				at(7) => dt.setHour(v),
				at(8) => dt.setMinute(v),
				at(9) => value._match(
					at(v is Integer) => dt.setSecond(v.int),
					at(v is types.Float) => {
						dt.setSecond(Std.int(v.float));
						dt.setMillisecond(Std.int((v.float - Std.int(v.float)) * 1000));
					},
					_ => invalid()
				),
				// TODO: most of these don't work and idk why
				at(10) => {
					final days = dateToDays(d);
					dt.date = daysToDate(
						days + (v - 1) + ((days + 2) % 7),
						cast dt.zone.float,
						hasTime
					);
				},
				at(11) => {
					dt.date = daysToDate(
						v + jan1stOf(d) - 1,
						cast dt.zone.float,
						hasTime
					);
				},
				at(13) => {
					var days = jan1stOf(d);
					if(v > 1) {
						final wd = (days + 3) % 7;
						days += ((v - 2) * 7) + 7 - wd;
					}
					dt.date = daysToDate(days, cast dt.zone.float, hasTime);
				},
				at(14) => {
					Util.detuple(@var [wd, d1], w11of(d));
					dt.date = daysToDate(
						((v - 1) * 7) + d1,
						cast dt.zone.float,
						hasTime
					);
				},
				_ => invalid()
			);
			return value;
			
		} else {
			return getField(parent, idx);
		}
	}
	
	override function compare(value1: Date, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(v2 is Date) => {
				final t1 = value1.date.asInt();
				final t2 = v2.date.asInt();

				return op._match(
					at(CEqual | CFind | CNotEqual | CStrictEqual | CSame) => cast (t1 != t2).asInt(),
					_ => if(t1 == t2) IsSame else if(js.Syntax.code("{0} < {1}", t1, t2)) IsLess else IsMore
				);
			},
			_ => return IsInvalid
		);
	}

	override function doMath(left: Value, right: Value, op: MathOp): Value {
		final l = cast(left, Date);
		if(!(op == OAdd || op == OSub)) invalid();

		right._match(
			at(r is Integer) => {
				final dt = l.date.copy();
				(cast dt : js.lib.Date).setDate(
					if(op == OAdd) dt.getDate() + r.int
					else dt.getDate() - r.int
				);
				return new Date(dt, l.zone);
			},
			at(r is Time) => {
				final h = r.hours;
				final m = r.minutes;
				final s = Std.int(r.seconds);
				final ms = Std.int((r.seconds - s) * 1000);
				final dt: js.lib.Date = cast l.date;
				if(op == OAdd) {
					dt.setHours(dt.getHours() + h);
					dt.setMinutes(dt.getMinutes() + m);
					dt.setSeconds(dt.getSeconds() + s);
					dt.setMilliseconds(dt.getMilliseconds() + ms);
				} else {
					dt.setHours(dt.getHours() - h);
					dt.setMinutes(dt.getMinutes() - m);
					dt.setSeconds(dt.getSeconds() - s);
					dt.setMilliseconds(dt.getMilliseconds() - ms);
				}
				return new Date(cast dt, l.zone);
			},
			at(r is Date) => {
				if(op == OAdd) invalid();
				return new Integer((cast l.date) - (cast r.date));
			},
			_ => invalid()
		);
	}


	/*-- Scalar actions --*/
	override function add(value1: Date, value2: Value) {
		return doMath(value1, value2, OAdd);
	}

	override function subtract(value1: Date, value2: Value) {
		return doMath(value1, value2, OSub);
	}

	
	/*-- Series actions --*/
	override function pick(date: Date, index: Value) {
		final idx = index._match(
			at(i is Integer) => i.int,
			at(w is Word) => getNamedIndex(w),
			_ => invalid()
		);
		if(idx < 1 || idx > 14) invalid();
		return getField(date, idx);
	}
}