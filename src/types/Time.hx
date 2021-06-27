package types;

import types.base.IGetPath;
import haxe.ds.Option;

class Time extends Value implements IGetPath {
	public var hours: Int;
	public var minutes: Int;
	public var seconds: StdTypes.Float;
	public var signed: Bool;

	public var sign(get, never): Int;
	inline function get_sign() return signed ? -1 : 1;
	
	public function new(hours: Int, minutes: Int, seconds: StdTypes.Float, signed: Bool = false) {
		this.hours = hours;
		this.minutes = minutes;
		this.seconds = seconds;
		this.signed = signed;
	}

	public function getPath(access: Value, ?ignoreCase = true): Option<Value> {
		return Util._match(access,
			at({int: 1} is Integer | (_.equalsString("hour", ignoreCase) => true) is Word) => Some(new Integer(hours * sign)),
			at({int: 2} is Integer | (_.equalsString("minute", ignoreCase) => true) is Word) => Some(new Integer(minutes)),
			at({int: 3} is Integer | (_.equalsString("second", ignoreCase) => true) is Word) => Some(new types.Float(seconds * sign)),
			_ => None
		);
	}
	
	public function toFloat() {
		return this.sign * (seconds + minutes*60 + hours*3600);
	}
}