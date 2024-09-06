package types;

import types.base.IGetPath;
import types.base._Float;
import haxe.ds.Option;

class Time extends _Float implements IGetPath {
	public static final ZERO = new Time(0);

	public var hours(get, never): Int;
	inline function get_hours() {
		return float < 0 ? Math.ceil(float / 3600) : Math.floor(float / 3600);
	}
	
	public var minutes(get, never): Int;
	inline function get_minutes() {
		return Math.floor(Math.abs(float) / 60) % 60;
	}
	
	public var seconds(get, never): Float;
	inline function get_seconds() {
		return float % 60;
	}
	
	public static inline function fromHMS(h: Int, m: Int, s: StdTypes.Float) {
		return new Time((Math.iabs(h)*3600 + (m*60) + s) * h.sign());
	}
	
	function make(value: StdTypes.Float): Time {
		return new Time(value);
	}
	
	public function getPath(access: Value, ?ignoreCase = true): Option<Value> {
		return access._match(
			at({int: 1} is Integer | (_.symbol.equalsString("hour", ignoreCase) => true) is Word) => Some(new Integer(hours)),
			at({int: 2} is Integer | (_.symbol.equalsString("minute", ignoreCase) => true) is Word) => Some(new Integer(minutes)),
			at({int: 3} is Integer | (_.symbol.equalsString("second", ignoreCase) => true) is Word) => Some(new types.Float(seconds)),
			_ => None
		);
	}
}