package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.Value;
import types.String;
import types.Email;
import types.Integer;
import types.Pair;
import types.Logic;

class EmailActions extends StringActions<Email> {
	override function mold(
		value: Email, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		return form(value, buffer, arg, part);
	}
}