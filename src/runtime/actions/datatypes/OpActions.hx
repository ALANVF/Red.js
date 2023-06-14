package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Function;
import types.Value;
import types.Op;
import types.Function;

import runtime.actions.Mold;

class OpActions extends _IFunctionActions<Op> {
	override function make(_, spec: Value) {
		spec._match(
			at(fn is _Function) => return new Op(fn),
			_ => throw "bad"
		);
	}

	override function form(value: Op, buffer: types.String, arg: Null<Int>, part: Int) {
		buffer.appendLiteral("?op?");
		return part - 4;
	}

	override function mold(
		value: Op, buffer: types.String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		buffer.appendLiteral("make op! [");
		part -= 9;
		final hasBody = value.fn is Function;
		final pre = hasBody ? "func " : "[";
		buffer.appendLiteral(pre);
		part -= pre.length;

		part = Mold._call(
			value.origSpec, buffer,
			isOnly, isAll, isFlat,
			arg, part,
			indent
		);

		if(hasBody) {
			part = Mold._call(
				(cast value.fn : Function).body, buffer,
				false, isAll, isFlat,
				arg, part,
				indent
			);
		} else {
			buffer.appendChar(']'.code);
			part--;
		}
		return part;
	}

	override function compare(value1: Op, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(other is Op) => op._match(
				at( CEqual
				  | CFind
				  | CSame
				  | CStrictEqual
				  | CNotEqual
				  | CSort
				  | CCaseSort
				) => {
					return value1.fn == other.fn ? IsSame : IsLess;
				},
				_ => return IsInvalid
			),
			_ => return IsInvalid
		);
	}
}