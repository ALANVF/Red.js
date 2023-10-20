package runtime;

import haxe.extern.EitherType;

import types.base.ComparisonOp;
import types.base.CompareResult;
import types.Value;
import types.Function;

enum abstract SortingFlag(Int) {
	final NORMAL;
	final REVERSE;
	final ALL;
}

typedef CustomSortingFunc<T> = (T, T, Function, Int) -> CompareResult;

typedef _SortingFunc<T> = EitherType<
	CustomSortingFunc<T>,
	(T, T, ComparisonOp, Int) -> CompareResult
>;

abstract SortingFunc<T>(_SortingFunc<T>) from _SortingFunc<T> {
	@:op(A()) public extern overload inline function call(
		v1: T,
		v2: T,
		op: EitherType<Function, ComparisonOp>,
		flags: Int
	): Int {
		return (untyped this)(v1, v2, op, flags);
	}
}

class Sort {

public static inline final REVERSE_MASK = 0x01;
public static inline final ALL_MASK = 0x02;

static inline function sortSwapN<T>(
	base: Array<T>,
	aOffset: Int, bOffset: Int,
	n: Int,
	width: Int
) {
	for(_ in 0...n) {
		swapFunc(base, aOffset, bOffset, width);
		aOffset += width;
		bOffset += width;
	}
}

static function swapFunc<T>(
	base: Array<T>,
	aOffset: Int, bOffset: Int,
	n: Int
	//swapType: Int
) {
	/*if(swapType == 0) {
		final cnt = n >> 2;
		var i = aOffset;
		var j = bOffset;
		for(_ in 0...cnt) {
			Macros.swap(a[i], b[j]);
			i++;
			j++;
		}
	} else {*/
		var i = aOffset;
		var j = bOffset;
		for(_ in 0...n) {
			Macros.swap(base[i], base[j]);
			i++;
			j++;
		}
	//}
}

static function med3<T>(
	base: Array<T>,
	aOffset: Int, bOffset: Int, cOffset: Int,
	op: EitherType<Function, ComparisonOp>,
	flags: Int,
	cmpFunc: SortingFunc<T>
): Int {
	return if(cmpFunc(base[aOffset], base[bOffset], op, flags) < 0) {
		if(cmpFunc(base[bOffset], base[cOffset], op, flags) < 0) {
			bOffset;
		} else {
			if(cmpFunc(base[aOffset], base[cOffset], op, flags) < 0) {
				cOffset;
			} else {
				aOffset;
			}
		}
	} else {
		if(cmpFunc(base[bOffset], base[cOffset], op, flags) > 0) {
			bOffset;
		} else {
			if(cmpFunc(base[aOffset], base[cOffset], op, flags) < 0) {
				aOffset;
			} else {
				cOffset;
			}
		}
	}
}

public static function quickSort<T>(
	base: Array<T>, baseOffset: Int,
	num: Int,
	width: Int,
	op: EitherType<Function, ComparisonOp>,
	flags: Int,
	cmpFunc: SortingFunc<T>
) {
	var
		aOffset = 0,
		bOffset = 0,
		cOffset = 0,
		dOffset = 0,
		mOffset = 0,
		nOffset = 0,
		endOffset = 0,
		iOffset = 0,
		jOffset = 0,
		r = 0,
		part = 0,
		result = 0,
		swapped = false;
	
	do {
		swapped = false;
		endOffset = baseOffset + (num * width);

		if(num < 7) {
			mOffset = baseOffset + width;
			while(mOffset < endOffset) {
				nOffset = mOffset;
				while(
					nOffset > baseOffset
					&& cmpFunc(base[nOffset - width], base[nOffset], op, flags) > 0
				) {
					swapFunc(base, nOffset - width, nOffset, width);
					nOffset -= width;
				}
				mOffset += width;
			}
			return;
		}
		mOffset = baseOffset + (Std.int(num / 2) * width);
		if(num > 7) {
			aOffset = baseOffset;
			bOffset = baseOffset + ((num - 1) * width);
			if(num > 40) {
				part = (num >> 3) * width;
				aOffset = med3(base, aOffset, aOffset + part, aOffset + (2 * part), op, flags, cmpFunc);
				mOffset = med3(base, mOffset - part, mOffset, mOffset + part, op, flags, cmpFunc);
				bOffset = med3(base, bOffset - (2 * part), bOffset - part, bOffset, op, flags, cmpFunc);
			}
			mOffset = med3(base, aOffset, mOffset, bOffset, op, flags, cmpFunc);
		}
		swapFunc(base, baseOffset, mOffset, width);
		aOffset = baseOffset + width;
		bOffset = aOffset;

		cOffset = baseOffset + ((num - 1) * width);
		dOffset = cOffset;
		while(true) {
			while(bOffset <= cOffset) {
				result = cmpFunc(base[bOffset], base[baseOffset], op, flags);
				if(result > 0) break;
				if(result == 0) {
					swapped = true;
					swapFunc(base, aOffset, bOffset, width);
					aOffset += width;
				}
				bOffset += width;
			}
			while(bOffset <= cOffset) {
				result = cmpFunc(base[cOffset], base[baseOffset], op, flags);
				if(result < 0) break;
				if(result == 0) {
					swapped = true;
					swapFunc(base, cOffset, dOffset, width);
					dOffset += width;
				}
				cOffset += width;
			}
			if(bOffset > cOffset) break;
			swapFunc(base, bOffset, cOffset, width);
			swapped = true;
			bOffset += width;
			cOffset -= width;
		}
		if(!swapped) {
			mOffset = baseOffset + width;
			while(mOffset < endOffset) {
				nOffset = mOffset;
				while(
					nOffset > baseOffset
					&& cmpFunc(base[nOffset - width], base[nOffset], op, flags) > 0
				) {
					swapFunc(base, nOffset - width, nOffset, width);
					nOffset -= width;
				}
				mOffset += width;
			}
			return;
		}
		r = (aOffset - baseOffset).min(bOffset - aOffset);
		if(r > 0) swapFunc(base, baseOffset, bOffset - r, r);

		r = (dOffset - cOffset).min(endOffset - dOffset - width);
		if(r > 0) swapFunc(base, bOffset, endOffset - r, r);

		r = bOffset - aOffset;
		if(r > width) {
			quickSort(base, baseOffset, Std.int(r / width), width, op, flags, cmpFunc);
		}
		r = dOffset - cOffset;
		if(r > width) {
			baseOffset = endOffset - r;
			num = Std.int(r / width);
		}
	} while(r <= width);
}

static function grailRotate<T>(
	base: Array<T>, baseOffset: Int,
	n1: Int, n2: Int,
	width: Int
) {
	while(n1 != 0 && n2 != 0) {
		final endOffset = baseOffset + (n1 * width);
		var b1Offset = endOffset;
		if(n1 <= n2) {
			sortSwapN(base, baseOffset, endOffset, n1, width);
			baseOffset = b1Offset;
			n2 -= n1;
		} else {
			b1Offset = baseOffset + ((n1 - n2) * width);
			sortSwapN(base, b1Offset, endOffset, n2, width);
			n1 -= n2;
		}
	}
}

static function grailSearchLeft<T>(
	base: Array<T>, baseOffset: Int,
	num: Int,
	keyOffset: Int,
	width: Int,
	op: EitherType<Function, ComparisonOp>,
	flags: Int,
	cmpFunc: SortingFunc<T>
) {
	var a = -1;
	var b = num;
	var c;
	while(a < b - 1) {
		c = a + ((b - a) >> 1);
		if(0 <= cmpFunc(base[baseOffset + (c * width)], base[keyOffset], op, flags)) {
			b = c;
		} else {
			a = c;
		}
	}
	return b;
}

static function grailSearchRight<T>(
	base: Array<T>, baseOffset: Int,
	num: Int,
	keyOffset: Int,
	width: Int,
	op: EitherType<Function, ComparisonOp>,
	flags: Int,
	cmpFunc: SortingFunc<T>
) {
	var a = -1;
	var b = num;
	var c;
	while(a < b - 1) {
		c = a + ((b - a) >> 1);
		if(cmpFunc(base[baseOffset + (c * width)], base[keyOffset], op, flags) > 0) {
			b = c;
		} else {
			a = c;
		}
	}
	return b;
}

static function grailMergeNoBuf<T>(
	base: Array<T>, baseOffset: Int,
	n1: Int, n2: Int,
	width: Int,
	op: EitherType<Function, ComparisonOp>,
	flags: Int,
	cmpFunc: SortingFunc<T>
) {
	if(n1 < n2) {
		final h = grailSearchLeft(
			base, baseOffset + (n1 * width),
			n2,
			baseOffset,
			width, op, flags, cmpFunc
		);
		if(h != 0) {
			grailRotate(base, baseOffset, n1, h, width);
			baseOffset += h * width;
			n2 -= h;
		}
		if(n2 == 0) {
			n1 = 0;
		} else {
			do {
				baseOffset += width;
				n1--;
			} while(!(
				n1 == 0
				|| cmpFunc(base[baseOffset], base[baseOffset + (n1 * width)], op, flags) > 0
			));
		}
	} else {
		final h = grailSearchRight(
			base, baseOffset,
			n1,
			baseOffset + ((n1 + n2 - 1) * width),
			width, op, flags, cmpFunc
		);
		if(h != n1) {
			grailRotate(base, baseOffset + (h * width), n1 - h, n2, width);
			n1 = h;
		}
		if(n1 == 0) {
			n2 = 0;
		} else {
			do {
				n2--;
			} while(!(
				n2 == 0
				|| cmpFunc(base[baseOffset + ((n1 - 1) * width)], base[baseOffset + ((n1 + n2 - 1) * width)], op, flags) > 0
			));
		}
	}
}

static function grailClassicMerge<T>(
	base: Array<T>, baseOffset: Int,
	n1: Int, n2: Int,
	width: Int,
	op: EitherType<Function, ComparisonOp>,
	flags: Int,
	cmpFunc: SortingFunc<T>
) {
	if(n1 < 9 || n2 < 9) {
		grailMergeNoBuf(base, baseOffset, n1, n2, width, op, flags, cmpFunc);
		return;
	}
	var k = n1 < n2 ? n1 + Std.int(n2 / 2) : Std.int(n1 / 2);
	var ak = baseOffset + (k * width);
	var k1 = grailSearchLeft(base, baseOffset, n1, ak, width, op, flags, cmpFunc);
	var k2 = k1;
	if(k2 < n1 && cmpFunc(base[baseOffset + (k2 * width)], base[ak], op, flags) == 0) {
		k2 = k1 + grailSearchRight(base, baseOffset + (k1 * width), n1 - k1, ak, width, op, flags, cmpFunc);
	}
	var m1 = grailSearchLeft(base, baseOffset + (n1 * width), n2, ak, width, op, flags, cmpFunc);
	var m2 = m1;
	if(m2 < n2 && cmpFunc(base[baseOffset + ((n1 + m2) * width)], base[ak], op, flags) == 0) {
		m2 = m1 + grailSearchRight(base, baseOffset + ((n1 + m1) * width), n2 - m1, ak, width, op, flags, cmpFunc);
	}
	if(k1 == k2) {
		grailRotate(base, baseOffset + (k2 * width), n1 - k2, m2, width);
	} else {
		grailRotate(base, baseOffset + (k1 * width), n1 - k1, m1, width);
		if(m2 != m1) grailRotate(base, baseOffset + ((k2 + m1) * width), n1 - k2, m2 - m1, width);
	}
	grailClassicMerge(base, baseOffset + ((k2 + m2) * width), n1 - k2, m2 - m1, width, op, flags, cmpFunc);
	grailClassicMerge(base, baseOffset, k1, m1, width, op, flags, cmpFunc);
}

public static function mergeSort<T>(
	base: Array<T>, baseOffset: Int,
	num: Int,
	width: Int,
	op: EitherType<Function, ComparisonOp>,
	flags: Int,
	cmpFunc: SortingFunc<T>
) {
	var h = 2;
	var m = 1;
	while(m < num) {
		final pm0 = baseOffset + ((m - 1) * width);
		final pm1 = baseOffset + (m * width);
		if(cmpFunc(base[pm0], base[pm1], op, flags) > 0) {
			swapFunc(base, pm0, pm1, width);
		}
		m += 2;
	}
	while(h < num) {
		var p0 = 0;
		var p1 = num - (2 * h);
		while(p0 <= p1) {
			grailClassicMerge(base, baseOffset + (p0 * width), h, h, width, op, flags, cmpFunc);
			p0 += 2 * h;
		}
		final rest = num - p0;
		if(rest > h) grailClassicMerge(base, baseOffset + (p0 * width), h, rest - h, width, op, flags, cmpFunc);
		h *= 2;
	}
}

}