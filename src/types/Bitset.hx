package types;

import types.base.ISetPath;
import types.base.IGetPath;
import types.base._Integer;
import haxe.ds.Option;
import haxe.io.Bytes;
import util.Set;

class Bitset extends Value /*implements IGetPath implements ISetPath*/ {
	public var bytes: Bytes;
	public var negated: Bool;

	public function new(bytes: Bytes, negated: Bool) {
		this.bytes = bytes;
		this.negated = negated;
	}

	public static function alloc(size: Int, negated: Bool = false) {
		final bytes = Bytes.alloc(size);
		// bytes.fill(0, size, 0); not needed with js
		return new Bitset(bytes, negated);
	}

	public static function fromChars(chars: Iterable<Char>, negated: Bool = false) {
		return _fromOrds(new Set([for(char in chars) char.int]), negated);
	}

	public static function fromIntegers(integers: Iterable<_Integer>, negated: Bool = false) {
		return _fromOrds(new Set([for(integer in integers) integer.int]), negated);
	}

	public static inline function fromOrds(ords: Iterable<Int>, negated: Bool = false) {
		return _fromOrds(new Set(ords), negated);
	}

	static inline function toByte(ord: Int) {
		//return 1 << (7 - (ord & 7));
		return 128 >> (ord & 7);
	}

	static function _fromOrds(ords: Set<Int>, negated: Bool) {
		var maxBit = (ords.length == 0) ? 0 : #if js
			js.Syntax.code("{0}(...{1})", js.lib.Math.max, ords);
		/*#elseif python
			switch ords.toArray() {
				case [ord]: ord;
				case ords: python.lib.Builtins.max(ords[0], ords[1], cast ords.slice(2));
			}
		#elseif php
			Std.int(php.Global.max(cast ords));
		#elseif lua
			Std.int(lua.Math.max(cast ords));*/
		#else
			Std.int(Lambda.fold(ords, Math.max, 0));
		#end

		final out = Bitset.alloc((maxBit >> 3) + 1, negated);
		
		for(ord in ords) {
			final i = ord >> 3;
			out.bytes.set(i, out.bytes.get(i) + toByte(ord));
		}

		return out;
	}

	public function setBit(bit: Int) {
		final i = bit >> 3;
		bytes.set(i, bytes.get(i) | toByte(bit));
	}

	public function clearBit(bit: Int) {
		final i = bit >> 3;
		bytes.set(i, bytes.get(i) & ~toByte(bit));
	}

	public function testBit(bit: Int) {
		final i = bit >> 3;
		return bytes.get(i) & toByte(bit) != 0;
	}

	/*public function hasBit(bit: Int, noCase: Bool = false /* ignore noCase for now * /) {
		final i = bit >> 3;

		return if(i >= this.bytes.length) {
			this.negated;
		} else {
			((toByte(bit) & this.bytes.get(i)) != 0) != this.negated;
		}
	}

	public function setBit(bit: Int, status: Bool) {
		final i = bit >> 3;
		final byte = toByte(bit);
		
		if(this.negated == status) {
			if(i < this.bytes.length) {
				this.bytes.set(i, this.bytes.get(i) & ~byte);
			}
		} else if(i >= this.bytes.length) {
			final size = this.bytes.length;
			final extraSize = i - size;
			final newBytes = Bytes.alloc(size + extraSize + 1);

			newBytes.blit(0, this.bytes, 0, size);
			newBytes.fill(size, extraSize, 0);
			newBytes.set(i, byte);

			this.bytes = newBytes;
		} else {
			this.bytes.set(i, this.bytes.get(i) | byte);
		}
	}

	public function getPath(access: Value, ?ignoreCase = false): Option<Value> {
		return Util._match(access,
			at({int: c} is Char | {int: c} is Integer, when(0 <= c)) => Some(Logic.fromCond(this.hasBit(c))),
			_ => None
		);
	}

	public function setPath(access: Value, newValue: Value, ?ignoreCase = false) {
		return Util._match([access, newValue],
			at([{int: c} is Char | {int: c} is Integer, {cond: status} is Logic], when(0 <= c)) => {
				this.setBit(c, status);
				true;
			},
			_ => false
		);
	}*/
}