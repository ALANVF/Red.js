package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.JsRoutine;
import types.Value;

class JsRoutineActions extends _IFunctionActions<JsRoutine> {
	// ...

	override function form(value: JsRoutine, buffer: types.String, arg: Null<Int>, part: Int) {
		buffer.appendLiteral("?js-routine?");
		return part - 12;
	}

	override function mold(
		value: JsRoutine, buffer: types.String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		buffer.appendLiteral("make js-routine! [");

		part = Mold._call(
			value.origSpec, buffer,
			isOnly, isAll, isFlat,
			arg, part - 18,
			indent
		);

		buffer.appendChar(']'.code);
		return part - 1;
	}

	override function compare(value1: JsRoutine, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(other is JsRoutine) => op._match(
				at( CEqual
				  | CFind
				  | CSame
				  | CStrictEqual
				  | CNotEqual
				  | CSort
				  | CCaseSort
				) => {
					return value1 == other ? IsSame : IsLess;
				},
				_ => return IsInvalid
			),
			_ => return IsInvalid
		);
	}
}