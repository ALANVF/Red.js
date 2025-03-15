package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.None;
import types.String;

class NoneActions extends ValueActions<None> {
	override function make(_, _) return None.NONE;

	override function to(_, _) return None.NONE;

	override function form(_, buffer: String, _, part: Int) {
		buffer.appendLiteral("none");
		return part - 4;
	}

	override function mold(_, buffer: String, _, isAll: Bool, _, _, part: Int, _) {
		if(isAll) {
			buffer.appendLiteral("#(none)");
			return part - 7;
		} else {
			return form(null, buffer, null, part);
		}
	}

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

	override function clear(none: None): None {
		return none;
	}
}