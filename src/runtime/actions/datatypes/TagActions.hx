package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.Value;
import types.Tag;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

class TagActions extends StringActions<Tag> {
	override function form(value: Tag, buffer: String, arg: Null<Int>, part: Int) {
		buffer.appendChar('<'.code);
		part = super.form(value, buffer, arg, part - 1);
		buffer.appendChar('>'.code);
		return part - 1;
	}

	override function mold(
		value: Tag, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		return form(value, buffer, arg, part);
	}
}