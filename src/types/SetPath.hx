package types;

import types.base._Path;

class SetPath extends _Path {
	function clone(values, ?index) return new SetPath(values, index);
}