package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Bitset;
import types.Logic;
import types.Integer;
import types.None;

class BitsetActions extends ValueActions<Bitset> {
	override function compare(value1: Bitset, value2: Value, op: ComparisonOp): CompareResult {
		final bitset2 = value2._match(
			at(bs is Bitset) => bs,
			_ => return IsInvalid
		);

		final bs1 = value1.bytes;
		final bs2 = bitset2.bytes;

		if(op == CSame) {
			return cast (bs1 != bs2).asInt();
		}

		final sz1 = bs1.length;
		final sz2 = bs2.length;

		if(sz1 != sz2) {
			return cast sz1.compare(sz2);
		}

		if(sz1 == 0) {
			return IsSame; // shortcut for empty bitsets
		}

		final not1 = value1.negated;
		final not2 = bitset2.negated;

		if(not1 != not2) {
			return cast not1.asInt().compare(not2.asInt());
		}

		var i = sz1 - 1;
		var b1 = 0, b2 = 0;
		while(i >= 0) {
			b1 = bs1.get(i);
			b2 = bs2.get(i);
			
			if(b1 != b2) break;
		}

		return cast b1.compare(b2);
	}
}