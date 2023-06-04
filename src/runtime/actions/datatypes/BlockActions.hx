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

class BlockActions<This: _Block = Block> extends _BlockLikeActions<This> {
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