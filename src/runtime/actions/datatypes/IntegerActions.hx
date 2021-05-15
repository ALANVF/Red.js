package runtime.actions.datatypes;

import types.base.ComparisonOp;
import types.base.CompareResult;
import types.Integer;
import types.Value;

class IntegerActions extends ValueActions {
	override public function compare(value1: Value, value2: Value, op: ComparisonOp) {
		if((op == CFind || op == CStrictEqual) && !(value2 is Integer)) {
			return IsMore;
		}
		
		final int = value1.as(Integer).int;
		final other = switch value2.KIND {
			case KInteger(i): i.int;
			case KChar(c): c.code;
			case KMoney(_): throw "todo!";
			case KFloat({float: f}) | KPercent({float: f}): f;
			case KTime(t): t.toFloat();
			default: return IsInvalid;
		};
		
		return cast js.lib.Math.sign(int - other);
	}
}