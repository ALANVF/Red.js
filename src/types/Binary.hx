package types;

import types.base._String;

// https://github.com/HaxeFoundation/haxe/blob/4.1.3/std/hl/types/ArrayBytes.hx
/*import types.base.ISeriesOf;
import haxe.io.BytesBuffer;
import haxe.io.Bytes;

class Binary extends Value implements ISeriesOf<Integer> {
	public var data: Bytes;

	public function new(data: Bytes) {
		
	}
}*/
class Binary extends _String {
	public static function fromString(str: std.String) {
		return new Binary(_String.codesFromRed(str));
	}
	
	function clone(values, ?index) {
		return new Binary(values, index);
	}
}