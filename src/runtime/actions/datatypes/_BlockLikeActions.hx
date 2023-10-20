package runtime.actions.datatypes;

import haxe.extern.EitherType;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._BlockLike;
import types.base._AnyWord;
import types.Hash;
import types.Path;
import types.LitPath;
import types.Value;
import types.Integer;
import types.Float;
import types.Pair;
import types.Logic;
import types.None;
import types.Datatype;
import types.Typeset;
import types.Function;

import runtime.Sort;

function compareEach(blk1: _BlockLike, blk2: _BlockLike, op: ComparisonOp): CompareResult {
	final isSame = blk1 == blk2 || (
		blk1.thisType() == blk2.thisType()
		&& blk1.values == blk2.values
		&& blk1.index == blk2.index
	);
	if(op == CSame) {
		if(isSame) {
			return IsSame;
		} else {
			return IsLess;
		}
	}
	if(isSame) return IsSame;
	if(Cycles.find(blk1.values)) {
		return cast Cycles.find(blk2.values) ? 0 : -1;
	}

	final size1 = blk1.length;
	final size2 = blk2.length;

	if(size1 != size2) op._match(
		at(CFind | CEqual | CNotEqual | CStrictEqual | CStrictEqualWord) => return IsMore,
		_ => {}
	);

	if(size1 == 0) return IsSame;

	final len = size1.min(size2);

	Cycles.push(blk1.values);
	Cycles.push(blk2.values);

	var res = IsSame;
	for(i in 0...len) {
		final v1 = blk1.fastPick(i);
		final v2 = blk2.fastPick(i);

		res = if(
			v1.thisType() == v2.thisType()
			|| (v1 is _AnyWord && v2 is _AnyWord)
			|| (
				(v1 is Integer || v1 is Float)
				&& (v2 is Float || v2 is Integer)
			)
		) {
			runtime.Actions.compareValue(v1, v2, op);
		} else {
			Cycles.popN(2);
			return cast MathTools.compare(cast v1.TYPE_KIND, cast v2.TYPE_KIND);
		};

		if(res != IsSame) break;
	}
	Cycles.popN(2);
	return if(res == IsSame) {
		cast size1.compare(size2);
	} else {
		res;
	};
}

abstract class _BlockLikeActions<This: _BlockLike> extends SeriesActions<This, Value, Value> {
	static function _insert(series: _BlockLike, value: Value, options: AInsertOptions, isAppend: Bool): _BlockLike {
		var cnt = 1;
		var part = -1;
		final isHash = series is Hash;
		var shouldRehash = false;
		if(isHash) {
			// ...
		}

		final isValues = !options.only && value is _BlockLike;

		options.part?.length._match(
			at(i is Integer) => {
				part = i.int;
			},
			at(b is _BlockLike) => {
				if(series.sameSeriesAs(b)) {
					part = b.index - series.index;
				} else {
					throw "bad";
				}
			},
			_ => {}
		);

		options.dup?.count._and(c => {
			cnt = c.int;
			if(cnt < 0) return series;
		});

		final src = (cast value : _BlockLike);
		final size = if(isValues) src.length else 1;
		if(part < 0 || part > size) part = size;

		final isTail = series.isTail() || isAppend;
		final slots = part * cnt;
		final index = if(isAppend) series.absLength - 1 else series.index;

		/*if(!isTail) {

		}*/

		final s = series.values;
		final blk = src.values;
		var head = series.index;
		while(cnt != 0) {
			if(isValues) {
				var cell = src.index;
				final limit = cell + part;
				
				if(isTail) {
					while(cell < limit) {
						s.push(blk[cell]);
						cell++;
					}
				} else { 
					while(cell < limit) {
						s.insert(head, blk[cell]);
						head++;
						cell++;
					}
				}
			} else {
				if(isTail) {
					s.push(value);
				} else {
					s.insert(head, value);
					head++;
				}
			}
			cnt--;
		}

		/*if(isHash) {

		}*/

		return if(isAppend) series.head() else {
			var idx = series.index + slots;
			if(idx >= series.absLength) {
				series.tail();
			} else {
				series.fastSkipHead(idx);
			}
		}
	}

	static function compareCall(value1: Value, value2: Value, fun: Function, flags: Int) {
		var v1, v2;
		if(flags & Sort.REVERSE_MASK == 0) {
			v1 = value2;
			v2 = value1;
		} else {
			v1 = value1;
			v2 = value2;
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


	override function compare(value1: This, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(blk is _BlockLike) => {
				if(value1.thisType() != blk.thisType()) {
					if(!(
						op == CStrictEqualWord
						&& (
							(value1 is Path && blk is LitPath)
							|| (value1 is LitPath && blk is Path)
						)
					)) {
						return IsInvalid;
					}
				}

				return compareEach(value1, blk, op);
			},
			_ => return IsInvalid
		);
	}

	override function append(series: This, value: Value, options: AAppendOptions): This {
		return cast _insert(series, value, cast options, true);
	}

	override function find(series: This, value: Value, options: AFindOptions): Value {
		final s = series.values;
		final beg = series.index;

		if(series.absLength == 0 || (!options.reverse && beg >= series.absLength)) {
			return None.NONE;
		}
		var step = 1;
		var isPart = false;
		var part = null;

		(options.skip?.size)._and(skip => {
			step = skip.int;
			if(step <= 0) throw "error";
		});
		(options.part?.length)._and(length => {
			part = length._match(
				at(i is Integer) => {
					if(i.int <= 0) return None.NONE;
					beg + i.int - 1;
				},
				at(b is _BlockLike) => {
					if(!(b.thisType() == series.thisType() && b.values == series.values)) {
						throw "bad";
					}
					b.index;
				},
				_ => throw "bad"
			);
			if(part >= series.absLength) part = series.absLength - 1;
			isPart = true;
		});

		final isDt = !options.only && value is Datatype;
		final isTs = !options.only && value is Typeset;
		var isAnyBlk = value is _BlockLike;
		var op = if(options._case) CStrictEqual else CFind;
		if(options.same) {
			op = CSame;
			if(options.only) isAnyBlk = false;
		}
		
		if(options.match || isAnyBlk || !(series is Hash)) {
			var valuesOffset = null;
			var values = null;
			var valuesCount = if(options.only) 0 else if(isAnyBlk) {
				final b: _BlockLike = cast value;
				valuesOffset = b.index;
				values = b;
				b.length; // >> 4 - b/head
			} else 0;
			if(valuesCount < 0) valuesCount = 0;

			var slot;
			var end;
			if(options.last) {
				step = -step;
				slot = part ?? if(valuesCount > 0) series.absLength - valuesCount else series.absLength - 1;
				end = 0;
			} else if(options.reverse) {
				step = -step;
				slot = part ?? if(valuesCount > 0) beg - valuesCount else beg - 1;
				end = 0;
				if(slot < end) return None.NONE;
			} else {
				slot = beg;
				end = if(isPart) part + 1 else series.absLength;
			}

			final isReverse = options.reverse || options.last;

			final type = if(isDt) (cast value : Datatype).kind else cast -1;

			var wasFound = false;
			do {
				if(valuesCount == 0) {
					final stype = s[slot].TYPE_KIND;
					wasFound =
						if(isDt) stype == type
						else if(isTs) (cast value : Typeset).types.has(Datatype.TYPES[stype])
						else Actions.compare(s[slot], value, op).cond;
				} else {
					var n = 0;
					var slot2 = slot;
					do {
						wasFound = Actions.compare(s[slot2], values.values[valuesOffset], op).cond;
						slot2++;
						n++;
					} while(!(
						!wasFound
						|| n == valuesOffset
						|| (isReverse && slot2 <= end)
						|| (!isReverse && slot2 >= end)
					));
					if(n <= valuesOffset && slot2 >= end) wasFound = false;
				}
				slot += step;
			} while(!(
				options.match
				|| (!options.match && wasFound)
				|| (isReverse && slot < end)
				|| (!isReverse && slot >= end)
			));
			if(options.tail) {
				if(valuesOffset > 0) {
					slot -= step + valuesOffset;
				} else if(isReverse) {
					slot -= step + 1;
				}
			} else {
				slot -= step;
			}

			if(wasFound) {
				return series.at(slot - series.index + (!options.reverse).asInt());
			} else {
				return None.NONE;
			}
		} else {
			throw "NYI";
		}

		return series;
	}

	override function insert(series: This, value: Value, options: AInsertOptions): This {
		return cast _insert(series, value, options, false);
	}

	override function select(series: This, value: Value, options: ASelectOptions): Value {
		var result = find(series, value, Macros.addFields(options, {match: false, tail: false}));
		
		if(result != None.NONE) {
			final offset = if(options.only) 1 else value._match(
				at(b is _BlockLike, when(!(value is Hash)
				)) => b.index,
				_ => 1
			);
			final blk: This = cast result;
			final s = blk.values;
			final p = blk.index + offset;
			if(p < blk.absLength) {
				result = s[p];
			} else {
				result = None.NONE;
			}
		}
		return result;
	}

	override function sort(series: This, options: ASortOptions) {
		var step = 1;
		var flags = 0;
		final s = series.values;
		var head = series.index;
		if(head == series.absLength) return series;
		var len = series.length;

		(options.part?.length)._and(part => {
			var len2 = part._match(
				at(i is Integer) => i.int,
				at(b is _BlockLike) => {
					if(!(series.thisType() == b.thisType() && series.values == b.values)) {
						throw "bad";
					}
					b.index - series.index;
				},
				_ => throw "bad"
			);
			if(len2 < len) {
				len = len2;
				if(len2 < 0) {
					len2 = -len2;
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
			if(step <= 0 || len % step != 0 || step > len) throw "bad";
			if(step > 1) untyped len /= step;
		}, {
			if(options.all) throw "bad";
		});

		if(options.reverse) flags |= Sort.REVERSE_MASK;
		var op: EitherType<Function, ComparisonOp> = options._case ? CCaseSort : CSort;
		var cmp: SortingFunc<Value> = Actions.compareValue;

		(options.compare?.comparator)._andOr(comparator => {
			comparator._match(
				at(f is Function) => {
					if(options.all && options.skip != null) {
						flags |= Sort.ALL_MASK;
						flags |= step << 2;
					}
					cmp = compareCall;
					op = f;
				},
				at(i is Integer) => {
					if(options.all || options.skip == null) throw "bad";
					final offset = i.int;
					if(offset < 1 || offset > step) throw "bad";
					flags |= (offset - 1) << 2;
				},
				_ => throw "bad"
			);
		}, {
			if(options.all) flags |= Sort.ALL_MASK;
		});
		if(options.stable) {
			Sort.mergeSort(series.values, head, len, step, op, flags, cmp);
		} else {
			Sort.quickSort(series.values, head, len, step, op, flags, cmp);
		}
		return series;
	}

	override function swap(series1: This, series2: Value): This {
		if(series1.length == 0) return series1;
		series2._match(
			at(s2 is _BlockLike) => {
				if(s2.length == 0) return series1;
				final value1 = series1.rawFastPick(0);
				final value2 = s2.rawFastPick(0);
				series1.rawFastPoke(0, value2);
				s2.rawFastPoke(0, value1);
				return series1;
			},
			_ => throw "bad"
		);
	}

	override function put(series: This, key: Value, value: Value, options: APutOptions): Value {
		final blk: This = cast find(series, key, Macros.addFields(Find.defaultOptions, {_case: options._case}));

		if((cast blk) == None.NONE) {
			series.values.push(key);
			series.values.push(value);
		} else {
			final s = blk.values;
			final slot = blk.index + 1;
			s[slot] = value;
		}

		return value;
	}
}