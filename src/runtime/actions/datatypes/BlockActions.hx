package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Path;
import types.base._Block;
import types.Value;
import types.Block;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

import runtime.actions.Form;
import runtime.actions.Mold;

class BlockActions<This: _Block = Block> extends _BlockLikeActions<This> {
	static function moldEach(
		blk: _Block, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		final head = blk.index;
		var value = head;
		final tail = blk.absLength;

		var lf = false;
		var depth = 0;

		Cycles.push(blk.values);

		while(value < tail) {
			if(arg != null && part <= 0) {
				Cycles.pop();
				return part;
			}
			depth++;
			if(!isFlat && blk.hasNewline(value)) {
				if(!isOnly && value == head) {
					lf = true;
					indent++;
				}
				if(!isOnly || value != head) {
					buffer.appendChar('\n'.code);
					part--;
				}
				for(_ in 0...indent) buffer.appendLiteral("    ");
				part -= indent * 4;
			}

			part = Mold._call(blk.values[value], buffer, false, isAll, isFlat, arg, part, indent);

			if(depth > 0) {
				buffer.appendChar(' '.code);
				part--;
			}

			depth--;
			value++;
		}
		Cycles.pop();

		if(value != head) {
			buffer.values.pop();
			part++;
		}
		if(lf) {
			indent--;
			buffer.appendChar('\n'.code);
			for(_ in 0...indent) buffer.appendLiteral("    ");
			part -= (indent * 4) + 1;
		}

		return part;
	}


	override function form(value: This, buffer: String, arg: Null<Int>, part: Int) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, false));
		if(cycle) return part;

		var c = 0;

		Cycles.push(value.values);
		
		for(i in value.index...value.absLength) {
			if(arg != null && part <= 0) {
				Cycles.pop();
				return part;
			}
			part = Form._call(value.values[i], buffer, arg, part);

			if(i + 1 == value.absLength) {
				c = buffer.length == 0 ? 0 : buffer.values.at(-1);
			}

			if(!(c == '\n'.code || c == '\r'.code || c == '\t'.code)) {
				buffer.appendChar(' '.code);
				part--;
			}
		}
		Cycles.pop();
		return part;
	}

	override function mold(
		value: This, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, true));
		if(cycle) return part;

		if(!isOnly) {
			buffer.appendChar('['.code);
			part--;
		}
		part = moldEach(value, buffer, isOnly, isAll, isFlat, arg, part, indent);

		if(!isOnly) {
			buffer.appendChar(']'.code);
			part--;
		}
		return part;
	}

	override function evalPath(
		parent: This, element: Value, value: Null<Value>,
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
}