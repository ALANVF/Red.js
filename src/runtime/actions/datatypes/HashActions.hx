package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.Value;
import types.Hash;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

class HashActions extends BlockActions<Hash> {
	override function makeThis(values: Array<Value>, ?index: Int, ?newlines: util.Set<Int>) {
		return cast new Hash(values, index, newlines);
	}


	override function mold(
		value: Hash, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		buffer.appendLiteral("make hash! ");
		return super.mold(value, buffer, isOnly, isAll, isFlat, arg, part - 11, indent);
	}
}