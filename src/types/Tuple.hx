package types;

import haxe.io.UInt8Array;

class Tuple extends Value {
	public final values: UInt8Array;

	public function new(values: UInt8Array) {
		if(values.length < 2 || values.length > 12) {
			throw "Invalid tuple!";
		} else {
			this.values = values;
		}
	}
}