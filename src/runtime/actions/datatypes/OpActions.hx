package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Function;
import types.Value;
import types.Op;

class OpActions extends ValueActions<Op> {
	override function make(_, spec: Value) {
		spec._match(
			at(fn is _Function) => return new Op(fn),
			_ => throw "bad"
		);
	}

	override function compare(value1: Op, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(other is Op) => op._match(
				at( CEqual
				  | CFind
				  | CSame
				  | CStrictEqual
				  | CNotEqual
				  | CSort
				  | CCaseSort
				) => {
					return value1.fn == other.fn ? IsSame : IsLess;
				},
				_ => return IsInvalid
			),
			_ => return IsInvalid
		);
	}
}