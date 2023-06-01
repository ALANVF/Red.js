package types;

import haxe.ds.Option;
import util.UInt8ClampedArray;
import types.base.IGetPath;

class Tuple extends Value implements IGetPath {
	public var values: UInt8ClampedArray; // TODO: use bitpacked int(s)

	public static inline function of(...values: Int) return new Tuple(UInt8ClampedArray.of(...values));
	
	public function new(values: UInt8ClampedArray) {
		if(values.length < 3 || values.length > 12) {
			throw "Invalid tuple!";
		} else {
			this.values = values;
		}
	}

	
	public function getPath(access:Value, ?_) {
		return access._match(
			at({int: i} is Integer, when(1 <= i && i <= values.length)) => Some(cast new Integer(values[i - 1])),
			_ => None
		);
	}
}