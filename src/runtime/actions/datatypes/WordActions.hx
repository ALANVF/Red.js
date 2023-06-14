package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Word;
import types.base._AnyWord;
import types.Value;
import types.Word;
import types.LitWord;
import types.Issue;
import types.Logic;
import types.String;

class WordActions<This: _Word = Word> extends ValueActions<This> {
	override function form(value: This, buffer: String, arg: Null<Int>, part: Int) {
		final name = value.symbol.name;
		buffer.appendLiteral(name);
		return part - name.length;
	}

	override function mold(value: This, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		return form(value, buffer, arg, part);
	}

	override function compare(value1: This, value2: Value, op: ComparisonOp): CompareResult {
		if((value2 is Issue && !(value1 is Issue)) || !(value2 is _Word)) {
			return IsInvalid;
		}

		final other = (untyped value2 : _Word);

		op._match(
			at(CEqual | CNotEqual | CFind) => {
				return cast (!value1.equalsWord(other)).asInt();
			},
			at(CStrictEqual) => {
				return cast (
					value1.thisType() != other.thisType()
					|| value1.symbol != other.symbol
				).asInt();
			},
			at(CSame) => {
				return cast (
					value1.symbol != other.symbol
					|| value1.context != other.context
					|| value1.thisType() != other.thisType()
				).asInt();
			},
			at(CStrictEqualWord) => {
				if((value1 is Word && other is LitWord)
				|| (value1 is LitWord && other is Word)) {
					return cast (value1.symbol != other.symbol).asInt();
				} else {
					return cast (
						value1.thisType() != other.thisType()
						|| value1.symbol != other.symbol
					).asInt();
				}
			},
			_ => {
				// TODO: find a better solution for this
				final str1 = value1.symbol.name.toUpperCase();
				final str2 = other.symbol.name.toUpperCase();
				return if(str1 == str2) IsSame
					else if(str1 < str2) IsLess
					else IsMore;
			}
		);
	}
}