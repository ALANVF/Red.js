package runtime.actions.datatypes;

import util.UInt8ClampedArray;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.Value;
import types.Url;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

class UrlActions extends StringActions<Url> {
	override function mold(
		value: Url, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		final hasLimit = arg != null;
		
		var num = 0;
		final p = new UInt8ClampedArray(3);
		for(i in value.index...value.absLength) {
			final size = StringActions.encodeUrlChar(false, p, value.values[i]);
			for(j in 0...size) {
				buffer.appendChar(p[j]);
				num++;
				if(hasLimit && num >= part) return part - num;
			}
		}
		return part - num;
	}
}