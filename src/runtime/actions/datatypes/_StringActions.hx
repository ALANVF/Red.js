package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._String;
import types.Value;
import types.Char;
import types.Integer;
import types.Pair;
import types.Logic;

abstract class _StringActions<This: _String> extends SeriesActions<This, Char> {
	// TODO: implement actual logic
	override function compare(value1: This, value2: Value, op: ComparisonOp): CompareResult {
		if(
			value1.thisType() != value2.thisType()
			&& (
				!(value2 is _String)
				|| (op != CEqual && op != CNotEqual)
			)
		) {
			return IsInvalid;
		}

		final str1 = value1;
		final str2 = (untyped value2 : _String);

		final isSame = str1 == str2 || (
			str1.thisType() == str2.thisType()
			&& str1.values == str2.values
			&& str1.index == str2.index
		);
		if(op == CSame) {
			if(isSame) {
				return IsSame;
			} else {
				return IsLess;
			}
		}
		if(isSame) op._match(
			at(CEqual | CFind | CStrictEqual | CNotEqual) => return IsSame,
			_ => {}
		);

		final size1 = str1.length;
		final size2 = str2.length;

		if(size1 != size2) op._match(
			at(CFind | CEqual | CNotEqual | CStrictEqual | CStrictEqualWord) => return IsMore,
			_ => {}
		);

		if(size1 == 0) return IsSame;

		final len = size1.min(size2);
		
		var c1: Char = untyped null;
		var c2: Char = untyped null;
		final isCase = (op == CStrictEqual || op == CCaseSort);
		for(i in 0...len) {
			c1 = str1.fastPick(i);
			c2 = str2.fastPick(i);

			if(!isCase) {
				c1 = c1.toUpperCase();
				c2 = c2.toUpperCase();
			}

			if(c1 != c2) break;
		}
		
		return if(c1 == c2) {
			cast size1.compare(size2);
		} else {
			cast c1.int.compare(c2.int);
		}
	}
}