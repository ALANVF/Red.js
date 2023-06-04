package runtime.actions;

import types.base._Path;
import types.Value;

class EvalPath {
	public static function call(
		parent: Value, element: Value, value: Null<Value>,
		path: Null<_Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	) {
		return Actions.getFor(parent).evalPath(parent, element, value, path, gparent, pItem, index, isCase, isGet, isTail);
	}
}