package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Path;
import types.GetPath;
import types.Value;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

class GetPathActions extends PathActions<GetPath> {
	override function makeThis(values: Array<Value>, ?index: Int) {
		return new GetPath(values, index);
	}

	override function form(value: GetPath, buffer: String, arg: Null<Int>, part: Int) {
		buffer.appendChar(':'.code);
		return super.form(value, buffer, arg, part - 1);
	}

	override function mold(
		value: GetPath, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		buffer.appendChar(':'.code);
		return super.mold(value, buffer, isOnly, isAll, isFlat, arg, part - 1, 0);
	}
}