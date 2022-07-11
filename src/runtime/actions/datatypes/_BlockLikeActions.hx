package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._BlockLike;
import types.base._AnyWord;
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
	// TODO: track cycles

	final size1 = blk1.length;
	final size2 = blk2.length;

	if(size1 != size2) op._match(
		at(CFind | CEqual | CNotEqual | CStrictEqual | CStrictEqualWord) => return IsMore,
		_ => {}
	);

	if(size1 == 0) return IsSame;

	final len = size1.min(size2);

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
			return cast MathTools.compare(cast v1.TYPE_KIND, cast v2.TYPE_KIND);
		};

		if(res != IsSame) break;
	}

	return if(res == IsSame) {
		cast size1.compare(size2);
	} else {
		res;
	};
}

abstract class _BlockLikeActions<This: _BlockLike> extends SeriesActions<This, Value> {
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
}