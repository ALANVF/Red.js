package types;

import types.base._Path;

class GetPath extends _Path {
	function clone(values, ?index) return new GetPath(values, index);
}