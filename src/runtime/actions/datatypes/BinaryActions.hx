package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Path;
import types.Value;
import types.Binary;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

class BinaryActions extends SeriesActions<Binary, Integer, Int> {
	static function serialize(
		bin: Binary, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		isMold: Bool
	) {
		var head = bin.index;
		var tail = bin.absLength;
		final size = bin.length;

		buffer.appendLiteral("#{");
		part -= 2;

		var bytes = 0;
		if(size > 30 && !isFlat) {
			buffer.appendChar('\n'.code);
			part--;
		}

		while(head < tail) {
			buffer.appendLiteral(StringActions.byteToHex(bin.values[head]));
			bytes++;
			if(bytes % 32 == 0 && !isFlat) {
				buffer.appendChar('\n'.code);
				part--;
			}
			part -= 2;
			if(arg != null && part <= 0) return part;
			head++;
		}
		if(size > 30 && bytes % 32 != 0 && !isFlat) {
			buffer.appendChar('\n'.code);
			part--;
		}
		buffer.appendChar('}'.code);
		return part - 1;
	}


	override function form(value: Binary, buffer: String, arg: Null<Int>, part: Int) {
		return serialize(value, buffer, false, false, false, arg, part, false);
	}

	override function mold(
		value: Binary, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		return serialize(value, buffer, isOnly, isAll, isFlat, arg, part, true);
	}

	override function evalPath(
		parent: Binary, element: Value, value: Null<Value>,
		path: Null<_Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	): Value {
		return element._match(
			at(i is Integer) => {
				value._andOr(value => {
					poke(parent, i, value);
				}, {
					pick(parent, i);
				});
			},
			_ => throw "todo"
		);
	}

	override function compare(value1: Binary, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(bin2 is Binary) => {
				final bin1 = value1;

				final size1 = bin1.length;
				final size2 = bin2.length;

				if(size1 != size2) op._match(
					at(CFind | CEqual | CNotEqual | CStrictEqual | CStrictEqualWord) => return IsMore,
					_ => {}
				);

				if(size1 == 0) return IsSame;

				final len = size1.min(size2);

				var v1: Int = untyped null;
				var v2: Int = untyped null;
				for(i in 0...len) {
					v1 = bin1.fastPick(i).int;
					v2 = bin2.fastPick(i).int;

					if(v1 != v2) break;
				}

				return if(v1 == v2) {
					cast size1.compare(size2);
				} else {
					cast v1.compare(v2);
				}
			},
			_ => throw "error"
		);
	}
}