package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Unset;

class UnsetActions extends ValueActions<Unset> {
	override function make(_, _) return Unset.UNSET;

	override function to(_, _) return Unset.UNSET;

	override function form(_, _) return types.String.fromString("");

	override function mold(_, _) return types.String.fromString("");

	override function compare(value1: Unset, value2: Value, op: ComparisonOp): CompareResult {
		if(value2 is Unset) op._match(
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