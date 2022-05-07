package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.Value;
import types.Integer;
import types.Time;

@:build(runtime.NativeBuilder.build())
class Now {
	public static final defaultOptions = Options.defaultFor(NNowOptions);

	public static function call(options: NNowOptions): Value {
		var date = Date.now();
		final res = new types.Date(date);

		if(options.utc) {
			(untyped res.zone).float = 0.0; // optimization
			res.date = DateTools.delta(res.date, DateTools.minutes(res.date.getTimezoneOffset())); // remove stupid timezone
		}

		if(!options.precise) {
			(untyped res.date : js.lib.Date).setMilliseconds(0);
		}

		if(options.year) return new Integer(res.getYear())
		else if(options.month) return new Integer(res.getMonth())
		else if(options.day) return new Integer(res.getDay())
		else if(options.time) return new Time(res.getTime())
		else if(options.zone) return res.zone
		else if(options.date) return res.getDate()
		else if(options.weekday) return new Integer(res.getWeekday())
		else if(options.yearday) throw "NYI!"
		;
		
		return res;
	}
}