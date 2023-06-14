package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Path;
import types.Path;
import types.Value;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

import runtime.actions.Form;
import runtime.actions.Mold;

class PathActions<This: _Path = Path> extends _BlockLikeActions<This> {
	override function form(value: This, buffer: String, arg: Null<Int>, part: Int) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, false));
		if(cycle) return part;

		var value = value.asSeries();
		Cycles.push(value.values);

		while(value.isNotTail()) {
			part = Form._call(value.value, buffer, arg, part);
			if(arg != null && part <= 0) {
				Cycles.pop();
				return part;
			}
			++value;

			if(value.isNotTail()) {
				buffer.appendChar('/'.code);
				part--;
			}
		}
		Cycles.pop();
		return part;
	}

	override function mold(
		value: This, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, true));
		if(cycle) return part;

		var value = value.asSeries();
		Cycles.push(value.values);

		while(value.isNotTail()) {
			part = Mold._call(value.value, buffer, isOnly, isAll, isFlat, arg, part, 0);
			if(arg != null && part <= 0) {
				Cycles.pop();
				return part;
			}
			++value;

			if(value.isNotTail()) {
				buffer.appendChar('/'.code);
				part--;
			}
		}
		Cycles.pop();
		return part;
	}
}