package runtime.actions.datatypes;

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

	// ...

	override function insert(series: This, value: Value, options: AInsertOptions): This {
		return cast _insert(series, value, options, false);
	}
}