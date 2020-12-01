package types;

import types.base._Path;

class GetPath extends _Path {
	override function clone(values, ?index) return new GetPath(values, index);
}