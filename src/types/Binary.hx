package types;

import types.base._SeriesOf;

// https://github.com/HaxeFoundation/haxe/blob/4.1.3/std/hl/types/ArrayBytes.hx
/*import types.base.ISeriesOf;
import haxe.io.BytesBuffer;
import haxe.io.Bytes;

class Binary extends Value implements ISeriesOf<Integer> {
	public var data: Bytes;

	public function new(data: Bytes) {
		
	}
}*/
class Binary extends _SeriesOf<Integer, Int> {
	function clone(values, ?index) {
		return new Binary(values, index);
	}

	function wrap(value: Int) return new Integer(value);
	function unwrap(value: Integer) return value.int;
}