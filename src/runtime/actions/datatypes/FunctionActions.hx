package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import runtime.natives.Func;
import types.Value;
import types.Block;
import types.Function;

class FunctionActions extends ValueActions<Function> {
	override function make(_, spec: Value) {
		spec._match(
			at(block is Block) => if(block.length < 2) throw "invalid spec" else {
				Util._match([block.fastPick(0), block.fastPick(1)],
					at([spec2 is Block, body is Block]) => return Func.call(spec2, body),
					_ => throw "invalid spec"
				);
			},
			_ => throw "invalid spec"
		);
	}

	override function compare(value1: Function, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(other is Function) => op._match(
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