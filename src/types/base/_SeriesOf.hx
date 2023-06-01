package types.base;

import haxe.ds.Option;

abstract class _SeriesOf<T: Value> extends Value implements ISeriesOf<T> {
	public var index: Int;
	public var values: Array<T>;
	
	public var length(get, default): Int;
	function get_length() {
		return this.absLength - this.index;
	}

	public var absLength(get, default): Int;
	function get_absLength() {
		return this.values.length;
	}

	public function new(values: Array<T>, ?index: Int) {
		this.values = values;
		this.index = index ?? 0;
	}

	abstract function clone(values: Array<T>, ?index: Int): _SeriesOf<T>; // ugh, can't wait for polymorphic `this` types

	public function pick(index: Int) {
		return if(index >= this.length) {
			None;
		} else {
			Some(this.values[this.index + index]);
		}
	}

	public inline function fastPick(index: Int) {
		return this.values[this.index + index];
	}

	public function poke(index: Int, value: T) {
		if(index >= this.length) {
			throw "out of bounds!";
		} else {
			return this.values[this.index + index] = value;
		}
	}

	public inline function fastPoke(index: Int, value: T) {
		return this.values[this.index + index] = value;
	}
	
	public function remove() {
		if(this.isTail()) {
			throw "out of bounds!";
		} else {
			return this.values.splice(this.index, 1)[0];
		}
	}
	
	public function removePart(count: Int) {
		return this.values.splice(this.index, count);
	}
	
	public function at(index: Int) {
		return this.clone(
			this.values,
			(this.index + (index <= 0 ? index : index - 1)).clamp(
				0,
				this.absLength
			)
		);
	}

	public function skip(index: Int) {
		return this.clone(
			this.values,
			(this.index + index).clamp(
				0,
				this.absLength
			)
		);
	}

	public function skipHead(index: Int) {
		return this.clone(
			this.values,
			index.clamp(
				0,
				this.absLength
			)
		);
	}

	public function fastSkipHead(index: Int) {
		return this.clone(
			this.values,
			index
		);
	}

	public function copy() {
		return this.clone(this.values.slice(this.index), 0);
	}

	public function head() {
		return this.clone(this.values, 0);
	}

	public function tail() {
		return this.clone(this.values, this.absLength);
	}
	
	public function isHead() {
		return this.index == 0;
	}

	public function isTail() {
		return this.index == this.absLength;
	}

	public inline function sameSeriesAs(other: _SeriesOf<T>) {
		return this.values == other.values;
	}

	public inline function iterator(): Iterator<T> {
		return values.slice(index).iterator();
	}

	public inline function keyValueIterator(): KeyValueIterator<Int, T> {
		return values.slice(index).keyValueIterator();
	}

	public function getPath(access: Value, ?ignoreCase = true) {
		return Util._match(access,
			at((_.int - 1 => i) is Integer, when(0 <= i)) => cast this.pick(i),
			_ => None
		);
	}

	public function setPath(access: Value, newValue: Value, ?ignoreCase = true) {
		return Util._match(access,
			at((_.int - 1 => i) is Integer, when(0 <= i)) => { // TODO: somehow typecheck against T
				this.poke(i, cast newValue);
				true;
			},
			_ => false
		);
	}
}