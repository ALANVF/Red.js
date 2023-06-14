package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Datatype;
import types.String;

class DatatypeActions extends ValueActions<Datatype> {
	override function form(value: Datatype, buffer: String, _, part: Int) {
		buffer.appendLiteralPart(value.name, value.name.length - 1);
		return part - value.name.length - 1;
	}

	override function mold(value: Datatype, buffer: String, _, isAll: Bool, _, _, part: Int, _) {
		buffer.appendLiteral(value.name);
		return part - value.name.length;
	}

	override function compare(value1: Datatype, value2: Value, op: ComparisonOp): CompareResult {
		op._match(
			at( CEqual
			  | CFind
			  | CSame
			  | CStrictEqual
			  | CNotEqual
			) => value2._match(
				at(other is Datatype) => {
					return value1.kind == other.kind ? IsSame : IsMore;
				},
				_ => return IsMore
			),
			_ => return IsInvalid
		);
	}
}