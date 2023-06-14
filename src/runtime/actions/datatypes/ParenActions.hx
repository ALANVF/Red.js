package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.Value;
import types.Paren;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

class ParenActions extends BlockActions<Paren> {
	override function mold(
		value: Paren, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		buffer.appendChar('('.code);
		part--;
		part = BlockActions.moldEach(value, buffer, isOnly, isAll, isFlat, arg, part, indent);
		buffer.appendChar(')'.code);
		return part - 1;
	}
}