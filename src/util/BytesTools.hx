package util;

import haxe.io.Bytes;

@:publicFields
class BytesTools {
	#if js
	static inline function copy(self: Bytes) {
		return @:privateAccess new Bytes(self.getData().slice(0));
	}

	static overload extern inline function _fill(self: Bytes, value: Int, start: Int, end: Int) @:privateAccess self.b.fill(value, start, end);
	static overload extern inline function _fill(self: Bytes, value: Int, start: Int) @:privateAccess self.b.fill(value, start);
	static overload extern inline function _fill(self: Bytes, value: Int) @:privateAccess self.b.fill(value);

	#end
}