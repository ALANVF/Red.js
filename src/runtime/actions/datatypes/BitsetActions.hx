package runtime.actions.datatypes;

import types.base.MathOp;
import types.base._ActionOptions;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Integer;
import types.base._Path;
import types.Value;
import types.Bitset;
import types.Integer;
import types.Char;
import types.Float;
import types.Block;
import types.None;
import types.Logic;
import types.String;
import types.Binary;
import types.Word;
import haxe.io.Bytes;

import runtime.actions.datatypes.ValueActions.invalid;

enum abstract BitsetOp(Int) {
	final OMax;
	final OSet;
	final OTest;
	final OClear;
}

enum abstract BitsetCmd(Int) {
	final CMake;
	final CTo;
	final COther;
}

class BitsetActions extends ValueActions<Bitset> {
	static function boundCheck(bits: Bitset, index: Int) {
		var s = bits.bytes;
		if((s.length << 3) <= index) {
			final byte = bits.negated ? 255 : 0;
			final b = Bytes.alloc((index >> 3) + 1);
			b._fill(byte, s.length);
			b.blit(0, s, 0, s.length);
			bits.bytes = s = b;
		}
	}

	static function isVirtualBit(bits: Bitset, index: Int) {
		final s = bits.bytes;
		final p = (index >> 3) + 1;
		return index < 0 || p > s.length || p < 0;
	}

	static function invertBytes(b: Bytes) {
		for(i in 0...b.length) {
			b.set(i, ~b.get(i));
		}
	}


	static function processRange(bits: Bitset, lower: Int, upper: Int, op: BitsetOp) {
		final isNot = bits.negated;

		op._match(
			at(OSet) => {
				Macros.processSetVirtual(bits, upper);
				for(i in lower...upper+1) {
					bits.setBit(i);
				}
			},
			at(OTest) => {
				if(isVirtualBit(bits, upper)) return isNot.asInt();
				for(i in lower...upper+1) {
					if(!bits.testBit(i)) return 0;
				}
			},
			at(OClear) => {
				Macros.processClearVirtual(bits, upper);
				for(i in lower...upper+1) {
					bits.clearBit(i);
				}
			},
			_ => {}
		);

		return 1;
	}

	static function processString(str: String, bits: Bitset, op: BitsetOp) {
		// TODO: unicode stuff

		var isSet = false;
		var max = 0;
		final size = str.length << 3;
		final isNot = bits?.negated ?? false;
		final isTest = op == OTest;

		for(p in str) {
			final cp = p.int;
			
			op._match(
				at(OMax) => {},
				at(OSet) => {
					bits.setBit(cp);
				},
				at(OTest) => {
					// idk what I'm doing wrong with these, but it's preventing `[not "abc"]` from working
					//if(size < cp) return isNot.asInt();
					isSet = bits.testBit(cp);
				},
				at(OClear) => {
					//if(size < cp) return isNot.asInt();
					bits.clearBit(cp);
				}
			);
			if(cp > max) max = cp;

			if(isTest && !isSet) return 0;
		}
		return isTest && isSet ? 1 : max;
	}

	static function process(spec: Value, bits: Bitset, op: BitsetOp, isSub: Bool, cmd: BitsetCmd) {
		var max = 0;
		final isNot = bits?.negated ?? false;

		spec._match(
			at(n is Char | n is Integer | n is Float) => {
				max = n.asInt();
				if(max < 0 && op != OTest) throw "out of range";
				op._match(
					at(OSet) => {
						Macros.processSetVirtual(bits, max);
						bits.setBit(max);
					},
					at(OTest) => {
						if(isVirtualBit(bits, max)) return isNot.asInt();
						max = bits.testBit(max).asInt();
					},
					at(OClear) => {
						Macros.processClearVirtual(bits, max);
						bits.clearBit(max);
					},
					_ => {}
				);
			},
			at(s is String) => {
				op._match(
					at(OSet) => {
						max = processString(s, bits, OMax);
						Macros.processSetVirtual(bits, max);
					},
					at(OClear) => {
						max = processString(s, bits, OMax);
						Macros.processClearVirtual(bits, max);
					},
					_ => {}
				);
				max = processString(s, bits, op);
			},
			at(b is Binary) => throw "NYI",
			at(b is Block) => {
				final tail = b.length;
				final isTest = op == OTest;
				
				var i = 0;
				while(i < tail) {
					final value = b.fastPick(i);
					var size = process(value, bits, op, true, cmd);
					if(isTest && size == 0) return 0;
					
					value._match(
						at(int1 is _Integer, when(i + 1 < tail)) => {
							b.fastPick(i + 1)._match(
								at(w is Word) => if(w.symbol == Words.DASH) {
									if(i + 2 == tail) throw "past end";
									b.fastPick(i + 2)._match(
										at(int2 is _Integer) => {
											if(int2.thisType() != int1.thisType()) invalid();
											final min = size;
											size = int2.int;
											if(min > size) throw "past end";
											op._match(
												at(OMax) => {},
												at(OSet) => processRange(bits, min, size, op),
												at(OTest) => max = processRange(bits, min, size, op),
												at(OClear) => processRange(bits, min, size, op)
											);
											i += 2;
										},
										_ => invalid()
									);
								},
								_ => {}
							);
						},
						_ => {}
					);
					if(size > max) max = size;
					i++;
				}
			},
			_ => cmd._match(
				at(CMake) => throw "bad make arg",
				at(CTo) => throw "bad to arg",
				_ => throw "invalid arg"
			)
		);

		if(!isSub && (op == OSet || op == OMax)) {
			max = ((max + 8) & -8) >> 3;
			if(max == 0) max = 1;
		}

		return max;
	}

	static function construct(spec: Value, cmd: BitsetCmd) {
		var bits: Bitset;
		var blk: Block = null;

		var isNot = false;
		spec._match(
			at(b is Block) => {
				blk = b;
				if(b.length > 0) {
					b.fastPick(0)._match(
						at(w is Word) => isNot = w.symbol == Words.NOT,
						_ => {}
					);
					if(isNot) b.index++;
					if(b.length > 0) {
						b.fastPick(0)._match(
							at(bn is Binary) => spec = bn,
							_ => {}
						);
					}
				}
			},
			_ => {}
		);

		spec._match(
			at(b is Bitset) => {
				bits = new Bitset(b.bytes.copy(), b.negated);
			},
			at(n is Float | n is Integer) => {
				if(cmd == CTo) throw "bad to arg";
				var size = n.asInt();
				if(size < 0) throw "out of range";
				size = if(size & 7 != 0) size else (size + 8) & -8;
				size >>= 3;
				bits = Bitset.alloc(size);
			},
			at(b is Binary) => {
				bits = Bitset.fromIntegers(b, isNot);
				if(isNot) {
					final bs = bits.bytes;
					for(i in 0...bs.length) {
						bs.set(i, ~bs.get(i));
					}
				}
			},
			_ => {
				final op = isNot ? OClear : OSet;
				
				final size = process(spec, null, OMax, false, cmd);
				bits = Bitset.alloc(size, isNot);
				if(isNot) bits.bytes._fill(255);
				process(spec, bits, op, false, cmd);
				if(isNot) blk.index--;
			}
		);

		return bits;
	}

	override function make(_, spec: Value) {
		return construct(spec, CMake);
	}

	override function to(_, spec: Value) {
		return construct(spec, CTo);
	}

	override function modify(target: Bitset, field: Word, value: Value, options: AModifyOptions) {
		return value;
	}

	override function evalPath(
		parent: Bitset, element: Value, value: Null<Value>,
		path: Null<_Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	): Value {
		return element._match(
			at(i is _Integer) => {
				value._andOr(value => {
					_poke(parent, i, value);
				}, {
					_pick(parent, i);
				});
			},
			_ => invalid()
		);
	}

	override function compare(value1: Bitset, value2: Value, op: ComparisonOp): CompareResult {
		final bitset2 = value2._match(
			at(bs is Bitset) => bs,
			_ => return IsInvalid
		);

		final bs1 = value1.bytes;
		final bs2 = bitset2.bytes;

		if(op == CSame) {
			return cast (bs1 != bs2).asInt();
		}

		final sz1 = bs1.length;
		final sz2 = bs2.length;

		if(sz1 != sz2) {
			return cast sz1.compare(sz2);
		}

		if(sz1 == 0) {
			return IsSame; // shortcut for empty bitsets
		}

		final not1 = value1.negated;
		final not2 = bitset2.negated;

		if(not1 != not2) {
			return cast not1.asInt().compare(not2.asInt());
		}

		var i = sz1 - 1;
		var b1 = 0, b2 = 0;
		while(i >= 0) {
			b1 = bs1.get(i);
			b2 = bs2.get(i);
			
			if(b1 != b2) break;
		}

		return cast b1.compare(b2);
	}

	static function doBitwise(left: Bitset, right: Value, op: MathOp) {
		final set1 = left;
		final set2 = right._match(
			at(b is Bitset) => b,
			_ => invalid()
		);

		var s1 = set1.bytes;
		var s2 = set2.bytes;
		final size1 = s1.length;
		final size2 = s2.length;
		var min = size1;
		var max = size2;
		if(min > max) Util.swap(min, max);
		final isSame = set1.negated == set2.negated;

		final node = Bitset.alloc(max, !isSame);
		var s = node.bytes;
		var p = 0;
		
		var p1 = 0;
		var p2 = 0;
		var i = 0;
		while(i < min) {
			s.set(i, op._match(
				at(OUnion | OOr) => s1.get(p1) | s2.get(p2),
				at(OIntersect | OAnd) => s1.get(p1) & s2.get(p2),
				at(ODifference | OXor) => s1.get(p1) ^ s2.get(p2),
				at(OExclude) => s1.get(p1) & ~s2.get(p2),
				_ => invalid()
			));
			p++;
			p1++;
			p2++;
			i++;
		}

		min = max - i;
		if(min != 0) {
			if(size2 < size1) {
				p2 = p1;
				s2 = s1;
			}
			op._match(
				at(OExclude) => {
					if(size1 > size2) s.blit(p, s2, p2, min);
					p += min;
				},
				at(OUnion | OOr) => {
					s.blit(p, s2, p2, min);
					p += min;
				},
				at(OIntersect) => {
					p += min;
				},
				at(OAnd) => {},
				at(ODifference | OXor) => {
					i = 0;
					do {
						s.set(p, 0 ^ s2.get(p2));
						p++;
						p2++;
						i++;
					} while(i != min);
				},
				_ => invalid()
			);
		}

		// TODO: seems like we should be negating the bytes at the end if both args are negated

		return node;
	}


	/*-- Scalar actions --*/

	override function negate(value: Bitset) {
		return complement(value);
	}


	/*-- Bitwise actions --*/

	override function complement(value: Bitset) {
		return new Bitset(value.bytes.copy(), !value.negated);
	}

	override function and(value1: Bitset, value2: Value) {
		return doBitwise(value1, value2, OAnd);
	}

	override function or(value1: Bitset, value2: Value) {
		return doBitwise(value1, value2, OOr);
	}

	override function xor(value1: Bitset, value2: Value) {
		return doBitwise(value1, value2, OXor);
	}


	/*-- Series actions --*/

	override function clear(bitset: Bitset) {
		final byte = bitset.negated ? 255 : 0;
		bitset.bytes._fill(byte);
		return bitset;
	}

	override function copy(bitset: Bitset, options: ACopyOptions) {
		return new Bitset(bitset.bytes.copy(), bitset.negated);
	}

	override function find(bitset: Bitset, value: Value, options: AFindOptions) {
		final bool = pick(bitset, value);
		return bool.cond ? bool : None.NONE;
	}

	override function insert(bitset: Bitset, value: Value, options: AInsertOptions) {
		process(value, bitset, OSet, false, COther);
		return bitset;
	}

	override function length_q(bitset: Bitset) {
		return new Integer(bitset.bytes.length << 3);
	}

	static function _pick(bitset: Bitset, index: Value) {
		final isSet = process(index, bitset, OTest, true, COther);
		return Logic.fromCond(isSet > 0);
	}

	override function pick(bitset: Bitset, index: Value) {
		return index._match(
			at(i is _Integer) => _pick(bitset, i),
			_ => invalid()
		);
	}

	static function _poke(bitset: Bitset, index: Value, value: Value) {
		final op = if(value._match(
			at(_ is None) => true,
			at(l is Logic) => l.cond,
			at(i is Integer) => i.int == 0,
			at(f is Float) => f.float == 0,
			_ => false
		)) OClear else OSet;
		process(index, bitset, op, false, COther);
		return value;
	}

	override function poke(bitset: Bitset, index: Value, value: Value) {
		return index._match(
			at(i is _Integer) => _poke(bitset, i, value),
			_ => invalid()
		);
	}

	override function remove(bitset: Bitset, options: ARemoveOptions) {
		final key = options?.key.keyArg ?? throw "missing arg";

		final op = bitset.negated ? OSet : OClear;
		process(key, bitset, op, false, COther);
		return bitset;
	}
}