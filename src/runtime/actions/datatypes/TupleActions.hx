package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Tuple;
import types.Integer;
import types.Logic;
import types.None;

class TupleActions extends ValueActions<Tuple> {
	override function compare(value1: Tuple, value2: Value, op: ComparisonOp): CompareResult {
		final tuple2 = value2._match(
			at(t is Tuple) => t,
			_ => return IsInvalid
		);

		final t1 = value1.values;
		final t2 = tuple2.values;
		final sz1 = t1.length;
		final sz2 = t2.length;
		final sz = sz1.max(sz2);

		for(i in 0...sz) {
			final v1 = i >= sz1 ? 0 : t1[i];
			final v2 = i >= sz2 ? 0 : t2[i];

			if(v1 != v2) {
				return cast v1.compare(v2);
			}
		}

		return IsSame;
	}
}