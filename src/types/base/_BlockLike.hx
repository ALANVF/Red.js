package types.base;

abstract class _BlockLike extends _SeriesOf<Value, Value> {
	abstract function clone(values: Array<Value>, ?index: Int): _BlockLike;

	function wrap(value: Value) return value;
	function unwrap(value: Value) return value;
}