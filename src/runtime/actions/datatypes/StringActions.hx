package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Path;
import types.base._String;
import types.Value;
import types.String;
import types.Char;
import types.Integer;
import types.Pair;
import types.Logic;
import types.Word;
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
}