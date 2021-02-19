package types;

import types.base._Path;

class Path extends _Path {
	function clone(values, ?index) return new Path(values, index);
}