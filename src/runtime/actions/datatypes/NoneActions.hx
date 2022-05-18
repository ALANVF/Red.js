package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.None;

class NoneActions extends ValueActions<None> {
	override function make(_, _) return None.NONE;

	override function to(_, _) return None.NONE;

	override function compare(value1: None, value2: Value, op: ComparisonOp): CompareResult {
		if(value2 is None) op._match(
			at( CEqual
			  | CFind
			  | CSame
			  | CStrictEqual
			  | CNotEqual
			  | CSort
			  | CCaseSort
			) => {
				return IsSame;
			},
			_ => {
				return IsInvalid;
			}
		) else {
			return IsInvalid;
		}
	}
}