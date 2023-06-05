package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Unset;
import types.String;

class UnsetActions extends ValueActions<Unset> {
	override function make(_, _) return Unset.UNSET;

	override function to(_, _) return Unset.UNSET;

	override function form(_, _, _, part: Int) {
		return part;
	}

	override function mold(_, buffer: String, _, _, _, _, part: Int, _) {
		buffer.appendLiteral("unset");
		return part - 5;
	}

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