package types;

import types.base.IGetPath;
import haxe.ds.Option;

class Time extends Value implements IGetPath {
	public var hours: Int;
	public var minutes: Int;
	public var seconds: StdTypes.Float;
	public var signed: Bool;

	public var sign(get, never): Int;
	function get_sign() return signed ? -1 : 1;
	
	public function new(hours: Int, minutes: Int, seconds: StdTypes.Float, signed: Bool = false) {
		this.hours = hours;
		this.minutes = minutes;
		this.seconds = seconds;
		this.signed = signed;
	}

	public function getPath(access: Value, ?ignoreCase = true): Option<Value> {
		return switch access.KIND {
			case KInteger(_.int => 1) | KWord(_.equalsString("hour", ignoreCase) => true): Some(new Integer(hours * sign));
			case KInteger(_.int => 2) | KWord(_.equalsString("minute", ignoreCase) => true): Some(new Integer(minutes));
			case KInteger(_.int => 1) | KWord(_.equalsString("second", ignoreCase) => true): Some(new types.Float(seconds * sign));
			default: None;
		};
	}
}