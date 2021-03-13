package types.base;

import haxe.ds.Option;

interface ISeriesOf<T: Value> extends IGetPath extends ISetPath {
	public var index: Int;
	public var length(get, default): Int;
	public var absLength(get, default): Int;

	public function pick(index: Int): Option<T>;
	
	public function poke(index: Int, value: T): T;
	
	public function at(index: Int): ISeriesOf<T>;
	
	public function skip(offset: Int): ISeriesOf<T>;

	public function copy(): ISeriesOf<T>;

	public function head(): ISeriesOf<T>;

	public function tail(): ISeriesOf<T>;

	public function isHead(): Bool;

	public function isTail(): Bool;
	
	public function iterator(): Iterator<T>;
}