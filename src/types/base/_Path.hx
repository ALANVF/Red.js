package types.base;

abstract class _Path extends _SeriesOf<Value> {
	abstract function clone(values: Array<Value>, ?index: Int): _Path; // ugh, can't wait for polymorphic `this` types
}