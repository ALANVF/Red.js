package types.base;

abstract class _BlockLike extends _SeriesOf<Value> {
	abstract function clone(values: Array<Value>, ?index: Int): _BlockLike;
}