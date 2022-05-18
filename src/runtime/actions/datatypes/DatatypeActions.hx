package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Datatype;

class DatatypeActions extends ValueActions<Datatype> {
	override function compare(value1: Datatype, value2: Value, op: ComparisonOp): CompareResult {
		op._match(
			at( CEqual
			  | CFind
			  | CSame
			  | CStrictEqual
			  | CNotEqual
			) => value2._match(
				at(other is Datatype) => {
					return value1.kind == other.kind ? IsSame : IsMore;
				},
				_ => return IsMore
			),
			_ => return IsInvalid
		);
	}
}