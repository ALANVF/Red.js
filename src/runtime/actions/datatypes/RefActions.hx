package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.Value;
import types.Ref;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

class RefActions extends StringActions<Ref> {
	override function mold(
		value: Ref, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		buffer.appendChar('@'.code);
		return form(value, buffer, arg, part - 1);
	}
}