package types.base;

class _Path extends _SeriesOf<Value> {
	override function clone(values: Array<Value>, ?index: Null<Int>): _Path { // ugh, can't wait for polymorphic `this` types
		throw "must be implemented by subclasses!";
	}
}