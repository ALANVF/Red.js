package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Path;
import types.SetPath;
import types.Value;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

class SetPathActions extends PathActions<SetPath> {
	override function makeThis(values: Array<Value>, ?index: Int) {
		return new SetPath(values, index);
	}

	override function form(value: SetPath, buffer: String, arg: Null<Int>, part: Int) {
		part = super.form(value, buffer, arg, part);
		buffer.appendChar(':'.code);
		return part - 1;
	}

	override function mold(
		value: SetPath, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		part = super.mold(value, buffer, isOnly, isAll, isFlat, arg, part, 0);
		buffer.appendChar(':'.code);
		return part - 1;
	}
}