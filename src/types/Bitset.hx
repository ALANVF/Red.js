package types;

import types.base.ISetPath;
import types.base.IGetPath;
import haxe.ds.Option;
import haxe.io.Bytes;
import util.Set;

class Bitset extends Value implements IGetPath implements ISetPath {
	public var bytes: Bytes;
	public final negated: Bool;

	function new(bytes: Bytes, negated: Bool) {
		this.bytes = bytes;
		this.negated = negated;
	}

	public static function alloc(size: Int, negated: Bool = false) {
		final bytes = Bytes.alloc(size);
		bytes.fill(0, size, 0);
		return new Bitset(bytes, negated);
	}

	public static function fromChars(chars: Iterable<Char>, negated: Bool = false) {
		return _fromOrds(new Set([for(char in chars) char.code]), negated);
	}

	public static function fromIntegers(integers: Iterable<Integer>, negated: Bool = false) {
		return _fromOrds(new Set([for(integer in integers) integer.int]), negated);
	}

	public static inline function fromOrds(ords: Iterable<Int>, negated: Bool = false) {
		return _fromOrds(new Set(ords), negated);
	}

	static inline function toByte(ord: Int) {
		return 1 << (7 - (ord & 7));
	}

	static function _fromOrds(ords: Set<Int>, negated: Bool) {
		var maxBit = (ords.length == 0) ? 0 : #if js
			js.Syntax.code("{0}(...{1}.repr)", js.lib.Math.max, ords);
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

	public function hasBit(bit: Int, noCase: Bool = false /* ignore noCase for now */) {
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
			at((_.code => c) is Char | (_.int => c) is Integer, when(0 <= c)) => Some(Logic.fromCond(this.hasBit(c))),
			_ => None
		);
	}

	public function setPath(access: Value, newValue: Value, ?ignoreCase = false) {
		return Util._match([access, newValue],
			at([(_.code => c) is Char | (_.int => c) is Integer, {cond: status} is Logic], when(0 <= c)) => {
				this.setBit(c, status);
				true;
			},
			_ => false
		);
	}
}