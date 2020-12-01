package types;

import types.base._Path;

class LitPath extends _Path {
	override function clone(values, ?index) return new LitPath(values, index);
}