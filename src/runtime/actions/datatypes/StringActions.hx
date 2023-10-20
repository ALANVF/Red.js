package runtime.actions.datatypes;

import haxe.extern.EitherType;
import util.Set;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Path;
import types.base._String;
import types.base._BlockLike;
import types.base._Block;
import types.base._Integer;
import types.Value;
import types.String;
import types.Binary;
import types.Char;
import types.Integer;
import types.Float;
import types.Pair;
import types.Logic;
import types.Word;
import types.None;
import types.Bitset;
import types.Function;

import runtime.Sort;

import util.UInt8ClampedArray;

class StringActions<This: _String = String> extends SeriesActions<This, Char, Int> {
	static inline final BRACES_THRESHOLD = 50;
	static inline final MAX_ESC_CHARS = 0x5F;
	static inline final MAX_URL_CHARS = 0x7F;
	static final ESCAPE_CHARS = UInt8ClampedArray.of(
		0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
		0x48, 0x2D, 0x2F, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
		0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57,
		0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
		0x00, 0x00, 0x22, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5E, 0x00
	);
	static final ESCAPE_URL_CHARS = UInt8ClampedArray.of(
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
		0x08, 0x09, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	);
	static final URI_ENCODE_TBL = UInt8ClampedArray.of(
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF,
		0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00
	);
	static final URL_ENCODE_TBL = UInt8ClampedArray.of(
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0xFF, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0x00, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF,
		0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00
	);
	static final WHITE_CHAR = new Set(
		[for(i in 0...33+1) i]
		.concat([
			133,
			160,
			5760,
			6158
		])
		.concat([for(i in 8192...8202+1) i])
		.concat([
			8232,
			8233,
			8239,
			8287,
			12288
		])
	);
	static final SPACE_CHAR = new Set(
		[
			32,
			9,
			133,
			160,
			5760,
			6158
		]
		.concat([for(i in 8192...8202+1) i])
		.concat([
			8232,
			8233,
			8239,
			8287,
			12288
		])
	);


	static inline function byteToHex(b: Int) {
		return b.toString(16).toUpperCase().padStart(2, "0");
	}

	static function sniffChars(str: _String, p: Int, len: Int): Tuple2<Int, Int> {
		var quote = 0;
		var nl = 0;

		for(i in p...len) {
			str.values[i]._match(
				at('"'.code) => quote++,
				at('\n'.code) => nl++,
				_ => {}
			);
		}

		return new Tuple2(quote, nl);
	}

	static function findRightBrace(str: _String, p: Int, len: Int) {
		var cnt = 0;

		for(i in 0...len) {
			str.values[i]._match(
				at('{'.code) => cnt++,
				at('\n'.code) => if(--cnt == 0) return true,
				_ => {}
			);
		}

		return false;
	}

	static function encodeUrlChar(isUri: Bool, pcode: UInt8ClampedArray, ch: Int): Int {
		final tbl = isUri ? URI_ENCODE_TBL : URL_ENCODE_TBL;
		final code = ch > MAX_URL_CHARS ? 0 : tbl[ch];
		return if(code == 0xFF) {
			pcode[0] = ch;
			return 1;
		} else {
			final str = byteToHex(ch);
			pcode[0] = '%'.code;
			pcode[1] = str.cca(0);
			pcode[2] = str.cca(1);
			return 3;
		}
	}

	static function _insert(string: _String, value: Value, options: AInsertOptions, isAppend: Bool) {
		final part = options.part._match(
			at(null) => -1,
			at({length: p}) => p._match(
				at(i is Integer) => i.int,
				at(s is _String) => s.absLength - s.index,
				at(b is _BlockLike) => b.absLength - b.index,
				_ => throw "bad"
			)
		);
		final str = Form.call(
			value,
			{part: {limit: new Integer(part)}}
		);
		var dupN = 1;
		var cnt = 1;
		options.dup._and(d => {
			cnt = d.count.int;
			if(cnt < 0) return string;
			dupN = cnt;
		});

		final s = string.values;
		final length = string.length;
		final isTail = length == 0 || isAppend;
		final index = isAppend ? length : string.index;

		var added = 0;
		while(cnt != 0) {
			var cell, limit, src, s2;
			value._match(
				at(b is _Block) => {
					src = b;
					s2 = src.values;
					cell = src.index;
					limit = src.absLength;
				},
				_ => {
					src = null;
					s2 = null;
					cell = -1;
					limit = 0;
				}
			);
			var rest = 0;
			added = 0;
			var formBuf: String;
			while(cell < limit && added != part) {
				final v = cell == -1 ? value : s2[cell];
				v._match(
					at(c is Char) => {
						if(isTail) {
							s.push(c.int);
						} else {
							s.insert(index, c.int);
						}
						added++;
					},
					_ => {
						// I feel like there's some unnecessary allocations here...
						if(v is _String && !(v is types.Tag || v is types.Binary)) {
							formBuf = (cast v : String).copy();
						} else {
							formBuf = new String([]);
							Form._call(v, formBuf, null, 0);
						}
						final len = formBuf.length;
						var rest = len;
						if(part > 0) {
							rest = part - added;
							if(rest > len) rest = len;
						}
						if(isTail) {
							string.append(formBuf, rest);
						} else {
							string.insert(formBuf, index + added, rest);
						}
						added += rest;
					}
				);
				cell++;
			}
			cnt--;
		}

		return if(isAppend) string else string.skip(added * dupN);
	}

	public static function changeRange(str: _String, cell: Value, cellIdx: Int, allAdded: {ref: Int}, limit: Int, hasPart: Bool) {
		var added = 0;

		while(cellIdx < limit) {
			cell._match(
				at(c is Char) => {
					if(hasPart) {
						str.values.insert(str.index, c.int);
					} else {
						str.values[str.index] = c.int;
					}
				},
				_ => {
					final formBuf = cell._match(
						at(s is _String, when(!(cell is types.Tag))) => {
							s.copy();
						},
						_ => {
							final buf = new String([]);
							Form._call(cell, buf, null, 0);
							buf;
						}
					);
					final len = allAdded.ref = formBuf.absLength;
					if(hasPart) {
						str.insert(formBuf, added, null);
					} else {
						str.overwrite(formBuf, added, null);
					}
					added += len;
				}
			);
			cellIdx++;
		}

		return added;
	}

	static function trimWith(str: _String, with: Null<Value>) {
		final withChars = with._match(
			at(i is _Integer) => new Set([i.int]),
			at(str2 is String | str2 is Binary) => {
				final s = str2.values;

				if(str2.length == 0) return;

				// fast path
				if(str2.index == 0) {
					new Set(s);
				} else {
					// ehh maybe get rid of extra allocation
					new Set(s.slice(str2.index));
				}
			},
			_ => new Set([9, 10, 13, 32])
		);

		final s = str.values;

		var c = 0;
		for(i in str.index...str.length) {
			if(!withChars.has(s[i])) {
				if(i > 0) {
					str.removeAt(0, c);
				}
				break;
			} else {
				c++;
			}
		}

		var i = str.length-1; while(i >= 0) {
			if(!withChars.has(s[i])) {
				if(i > 0) {
					str.removeAt(i+1, c);
				}
				break;
			} else {
				c++;
			}

			i--;
		}
	}

	static function trimLines(str: _String) {
		var pad = 0;
		final s = str.values;
		final head = str.index;
		final tail = str.absLength;
		
		for(cur in head...tail) {
			final char = s[cur];
			if(WHITE_CHAR.has(char)) {
				if(pad == 1) {
					s[cur] = ' '.code;
					pad = 2;
				}
			} else {
				pad = 1;
			}
		}
	}

	static function trimHeadTail(str: _String, isHead: Bool, isTail: Bool) {
		var appendLF = false;
		final s = str.values;
		var head = str.index;
		var tail = str.length;
		var cur = head;

		if(isHead || !isTail) {
			var char;
			while({char = s[head]; head < tail && WHITE_CHAR.has(char);}) {
				if(char == 10) appendLF = true;
				head++;
			}
		}

		if(isTail || !isHead) {
			var char;
			while({char = s[tail - 1]; head < tail && WHITE_CHAR.has(char);}) {
				if(char == 10) appendLF = true;
				tail--;
			}
		}

		if(!isHead && !isTail) {
			var outside = false;
			var left = 0;

			while(head < tail) {
				var skip = false;
				final char = s[head];
				
				if(SPACE_CHAR.has(char)) {
					if(outside) {
						skip = true;
					} else {
						if(left == 0) left = cur;
					}
				} else if(char == 10) {
					outside = true;
					if(left != 0) {
						cur = left;
						left = 0;
					}
				} else {
					outside = false;
					left = 0;
				}

				if(!skip) {
					s[cur] = char;
					cur++;
				}

				head++;
			}
		} else {
			str.removeAt(0, head);
			str.removeAt(tail, str.length);
			cur += (tail - head);
		}

		if(appendLF && !isTail) {
			s[cur] = 10;
		}
		
		s.resize(cur);
	}

	static function compareChar(c1: Int, c2: Int, op: ComparisonOp, flags: Int): CompareResult {
		// TODO: improve this
		final res = op._match(
			at(CCaseSort | CStrictEqual | CSame) => c1 - c2,
			_ => c1.toUpperCase() - c2.toUpperCase()
		);
		return cast if(flags & Sort.REVERSE_MASK != 0) -res else res;
	}

	static function compareCharCall(value1: Int, value2: Int, fun: Function, flags: Int) {
		var v1, v2;
		if(flags & Sort.REVERSE_MASK == 0) {
			v1 = Char.fromCode(value2);
			v2 = Char.fromCode(value1);
		} else {
			v1 = Char.fromCode(value1);
			v2 = Char.fromCode(value2);
		}

		final isAll = flags & Sort.ALL_MASK != 0;
		var num = flags >>> 2;
		if(isAll && num > 0) {
			// ???????????????????
		}

		final res = Eval.callFunction(fun, [v1, v2], new Dict());
		final res2 = res._match(
			at(l is Logic) => l.cond.asInt(),
			at(i is Integer) => i.int,
			at(f is Float) => Std.int(f.float),
			at(_ is None) => -1,
			_ => 1
		);
		return cast if(flags & Sort.REVERSE_MASK != 0) -res2 else res2;
	}


	override function form(value: This, buffer: String, arg: Null<Int>, part: Int) {
		buffer.append(value, arg);
		return part - value.length;
	}

	override function mold(
		value: This, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		final limit = arg ?? 0;

		final head = value.index;
		var p = head;

		final tail = (
			if(limit == 0) value.absLength
			else if(part < 0) p
			else (p + part).min(value.absLength)
		);

		var cBeg = 0;
		var conti = true;
		Util.detuple(@var [quote, nl], sniffChars(value, p, tail));

		var open: Int, close: Int;
		if(nl >= 3 || quote > 0 || BRACES_THRESHOLD <= value.length) {
			open = '{'.code;
			close = '}'.code;
		} else {
			open = close = '"'.code;
		}

		buffer.appendChar(open);

		while(p < tail) {
			final cp = value.values[p];
			if(open == '{'.code) {
				cp._match(
					at('{'.code) => {
						if(conti && !findRightBrace(value, p, tail)) {
							conti = false;
						}
						if(conti) {
							cBeg++;
						} else {
							buffer.appendChar('^'.code);
						}
						buffer.appendChar(cp);
					},
					at('}'.code) => {
						if(cBeg > 0) {
							cBeg--;
						} else {
							buffer.appendChar(cp);
						}
					},
					at('"'.code) => buffer.appendChar(cp),
					at('^'.code) => buffer.appendLiteral("^^"),
					_ => buffer.appendEscapedChar(cp, true, isAll)
				);
			} else {
				buffer.appendEscapedChar(cp, true, isAll);
			}
			p++;
		}

		buffer.appendChar(close);

		return part - (tail - head) - 2;
	}

	override function evalPath(
		parent: This, element: Value, value: Null<Value>,
		path: Null<_Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	): Value {
		return element._match(
			at(i is Integer) => {
				value._andOr(value => {
					poke(parent, i, value);
				}, {
					pick(parent, i);
				});
			},
			at(_ is Word) => throw "invalid path",
			_ => throw "todo"
		);
	}

	// TODO: implement actual logic
	override function compare(value1: This, value2: Value, op: ComparisonOp): CompareResult {
		if(
			value1.thisType() != value2.thisType()
			&& (
				!(value2 is _String)
				|| (op != CEqual && op != CNotEqual)
			)
		) {
			return IsInvalid;
		}

		final str1 = value1;
		final str2 = (untyped value2 : _String);

		final isSame = str1 == str2 || (
			str1.thisType() == str2.thisType()
			&& str1.values == str2.values
			&& str1.index == str2.index
		);
		if(op == CSame) {
			if(isSame) {
				return IsSame;
			} else {
				return IsLess;
			}
		}
		if(isSame) op._match(
			at(CEqual | CFind | CStrictEqual | CNotEqual) => return IsSame,
			_ => {}
		);

		final size1 = str1.length;
		final size2 = str2.length;

		if(size1 != size2) op._match(
			at(CFind | CEqual | CNotEqual | CStrictEqual | CStrictEqualWord) => return IsMore,
			_ => {}
		);

		if(size1 == 0) return IsSame;

		final len = size1.min(size2);
		
		var c1: Char = untyped null;
		var c2: Char = untyped null;
		final isCase = (op == CStrictEqual || op == CCaseSort);
		for(i in 0...len) {
			c1 = str1.fastPick(i);
			c2 = str2.fastPick(i);

			if(!isCase) {
				c1 = c1.toUpperCase();
				c2 = c2.toUpperCase();
			}

			if(c1 != c2) break;
		}
		
		return if(c1 == c2) {
			cast size1.compare(size2);
		} else {
			cast c1.int.compare(c2.int);
		}
	}

	override function append(string: This, value: Value, options: AAppendOptions): This {
		return cast _insert(string, value, cast options, true);
	}

	override function find(series: This, value: Value, options: AFindOptions): Value {
		final s = series.values;
		var head = series.index;
		var end = series.absLength;
		var len = series.length;

		if(head == end || (!options.reverse && head >= end)) {
			return None.NONE;
		}

		var step = 1;
		var isPart = false;

		// Options processing

		if(options.any || options.with != null) throw "NYI";

		(options.skip?.size)._and(skip => {
			step = skip.int;
			if(step < 1) throw "bad";
		});
		var sz = 0;
		var limit = 0;
		(options.part?.length)._and(part => {
			sz = part._match(
				at(i is Integer) => i.int,
				at(str is _String) => {
					if(!(str.thisType() == series.thisType() && str.values == series.values)) {
						throw "bad";
					}
					str.index - series.index;
				},
				_ => throw "bad"
			);
			if(sz <= 0) return None.NONE;
			if(sz > len) sz = len;
			isPart = true;
			limit = sz;
		});
		if(options.last) {
			step = -step;
			end = head;
			head = isPart ? head + limit : series.absLength;
			head -= 1;
		} else if(options.reverse) {
			step = -step;
			head = end + (head - 1);
			if(isPart) end = head - limit + 1;
			if(head < end || options.match) {
				return None.NONE;
			}
		} else {
			if(isPart) end = head + limit;
		}

		var isCase = !(series is Binary) ? !options._case : false;
		if(options.same) isCase = false;
		final isReverse = options.reverse || options.last;
		var pattern = null, end2 = null;
		var isBs = false;
		final isFloat = value is types.Float;
		var sz2 = 0;

		// Value argument processing

		var s2: Array<Int> = null;
		var c2 = 0;
		var bs: Bitset = null;
		var str2: _String = null;
		var head2 = 0;
		var cf2 = 0.0;
		inline function get2() {
			s2 = str2.values;
			pattern = str2.index + head2;
			end2 = str2.absLength;
			sz2 = end2 - pattern;
		}
		value._match(
			at(c is Char) => {
				c2 = c.int;
				if(isCase) c2 = c2.toUpperCase();
			},
			at(b is Bitset) => {
				bs = b;
				isBs = true;
				isCase = false;
			},
			at(str is _String) => {
				if(str is Binary && !(series is Binary)) throw "bad";
				str2 = str;
				head2 = str.index;
				get2();
			},
			at(w is Word) => {
				str2 = String.fromString(w.symbol.name);
				head2 = 0;
				get2();
			},
			_ => {
				if(series is Binary && (value is Integer || isFloat)) {
					if(isFloat) {
						cf2 = (cast value : types.Float).float;
					} else {
						c2 = (cast value : Integer).int;
					}
				} else {
					str2 = Form.call(value, Form.defaultOptions);
					head2 = 0;
					get2();
				}
			}
		);

		// Search loop
		var wasFound = false;
		do {
			if(pattern == null) {
				var c1 = s[head];
				if(isCase && !isFloat) c1 = c1.toUpperCase();
				if(isBs) {
					wasFound = bs.testBit(c1);
				} else {
					wasFound = /*isFloat ? cf1 == cf2*/ c1 == c2;
				}
				if(wasFound && options.tail && !isReverse) {
					head += step;
				}
			} else {
				var p1 = head;
				var end1 = end;
				if(isReverse) {
					sz = p1 - end + 1;
					if(sz < sz2) {
						wasFound = false;
						break;
					}
					p1 -= sz2 - 1;
					end1 = head + 1;
				}
				var p2: Int = pattern;
				do {
					var c1 = s[p1];
					var c2 = s2[p2];
					if(isCase) {
						c1 = c1.toUpperCase();
						c2 = c2.toUpperCase();
					}
					wasFound = c1 == c2;

					p1++;
					p2++;
				} while(!(
					!wasFound
					|| p2 >= end2
					|| p1 >= end1
				));
				if(wasFound && p2 < end2 && p1 >= end1) {
					wasFound = false;
				}

				if(wasFound) {
					if(isReverse) head = end1 - sz2;
					if(options.tail) head = p1;
				}
			}
			head += step;
		} while(!(
			options.match
			|| (!options.match && wasFound)
			|| (isReverse && head < end)
			|| (!isReverse && head >= end)
		));
		head -= step;
		if(options.tail && isReverse && pattern == null) {
			head -= step;
		}

		if(wasFound) {
			return series.rawAt(head - series.index);
		} else {
			return None.NONE;
		}
		
		return series;
	}

	override function insert(string: This, value: Value, options: AInsertOptions): This {
		return cast _insert(string, value, options, false);
	}

	override function select(series: This, value: Value, options: ASelectOptions): Value {
		final result = find(series, value, Macros.addFields(options, {tail: false, match: false}));

		if(result != None.NONE) {
			final offset = value._match(
				at(s is _String) => s.length,
				_ => 1
			);
			final str: This = cast result;
			final s = str.values;

			final p = str.index + offset;

			if(p < str.absLength) {
				final char = s[p];
				return str._match(
					at(_ is Binary) => new Integer(char),
					_ => Char.fromCode(char)
				);
			} else {
				return None.NONE;
			}
		}
		return result;
	}

	override function sort(series: This, options: ASortOptions): This {
		var step = 1;
		final s = series.values;
		var head = series.index;
		var end = series.absLength;
		var len = series.length;

		(options.part?.length)._and(part => {
			var len2 = part._match(
				at(i is Integer) => i.int,
				at(str is _String) => {
					if(!(str.thisType() == series.thisType() && str.values == series.values)) {
						throw "bad";
					}
					str.index - series.index;
				},
				_ => throw "bad"
			);
			if(len2 < len) {
				len = len2;
				if(len2 < 0) {
					len2 = - len2;
					series.index -= len2;
					len = if(series.index < 0) {
						series.index = 0;
						0;
					} else len2;
					head -= len;
				}
			}
		});
		if(len == 0) return series;
		
		(options.skip?.size)._andOr(skip => {
			step = skip.int;
			if(step <= 0 || len % step != 0 || step > len) {
				throw "bad";
			}
			if(step > 1) untyped len /= step;
		}, {
			if(options.all) throw "bad";
		});

		var cmp: Sort.SortingFunc<Int> = compareChar;
		var op: EitherType<Function, ComparisonOp> = options._case ? CStrictEqual : CEqual;
		var flags = options.reverse ? Sort.REVERSE_MASK : 0;

		(options.compare?.comparator)._andOr(comparator => {
			comparator._match(
				at(f is Function) => {
					if(options.all && options.skip != null) {
						flags |= Sort.ALL_MASK;
						flags |= step << 2;
					}
					cmp = compareCharCall;
					op = f;
				},
				at(i is Integer) => {
					if(options.all || options.skip == null) {
						throw "bad";
					}
					flags |= (i.int - 1) << 2;
				},
				_ => throw "bad"
			);
		}, {
			if(options.all && options.skip != null) {
				flags |= Sort.ALL_MASK;
				flags |= step << 2;
			}
		});

		Sort.quickSort(s, head, len, step, op, flags, cmp);

		return series;
	}

	override function trim(series: This, options: ATrimOptions) {
		if(options.all || options.with != null) trimWith(series, options.with.str);
		else if(options.auto) throw "NYI";
		else if(options.lines) trimLines(series);
		else trimHeadTail(series, options.head, options.tail);

		return series;
	}
}