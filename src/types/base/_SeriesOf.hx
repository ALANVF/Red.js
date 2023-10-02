package types.base;

import haxe.ds.Option;
import util.Series;

abstract class _SeriesOf<T: Value, V> extends Value implements ISeriesOf<T> {
	public var index: Int;
	public var values: Array<V>;
	
	public var length(get, default): Int;
	inline function get_length() {
		return this.absLength - this.index;
	}

	public var absLength(get, default): Int;
	inline function get_absLength() {
		return this.values.length;
	}

	public function new(values: Array<V>, ?index: Int) {
		this.values = values;
		this.index = index ?? 0;
	}

	abstract function clone(values: Array<V>, ?index: Int): _SeriesOf<T, V>; // ugh, can't wait for polymorphic `this` types

	abstract function wrap(value: V): T;
	abstract function unwrap(value: T): V; 

	public function cloneValues() {
		return this.values.slice(this.index);
	}

	public function pick(index: Int) {
		if(index < 0 || index >= this.length) {
			return null;
		} else {
			return fastPick(index);
		}
	}

	public function rawPick(index: Int) {
		if(index < 0 || index >= this.length) {
			return null;
		} else {
			return rawFastPick(index);
		}
	}

	public inline function fastPick(index: Int) {
		return wrap(this.values[this.index + index]);
	}

	public inline function rawFastPick(index: Int) {
		return this.values[this.index + index];
	}

	public function poke(index: Int, value: T) {
		if(index < 0 || index >= this.length) {
			return null;
		} else {
			return fastPoke(index, value);
		}
	}

	public function rawPoke(index: Int, value: V) {
		if(index < 0 || index >= this.length) {
			return null;
		} else {
			return rawFastPoke(index, value);
		}
	}

	public inline function fastPoke(index: Int, value: T) {
		this.values[this.index + index] = unwrap(value);
		return value;
	}

	public inline function rawFastPoke(index: Int, value: V) {
		return this.values[this.index + index] = value;
	}
	
	public function remove() {
		if(this.isTail()) {
			throw "out of bounds!";
		} else {
			return wrap(this.values.splice(this.index, 1)[0]);
		}
	}
	
	public function removePart(count: Int) {
		return this.values.splice(this.index, count).map(v -> wrap(v));
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

	public inline function sameSeriesAs(other: _SeriesOf<T, V>) {
		return this.values == other.values;
	}

	public inline function asSeries() {
		return new Series(values, index);
	}

	// TODO: make actual iterators for these so they're optimized
	public inline function iterator(): Iterator<T> {
		return values.slice(index).map(v -> wrap(v)).iterator();
	}

	public inline function keyValueIterator(): KeyValueIterator<Int, T> {
		return values.slice(index).map(v -> wrap(v)).keyValueIterator();
	}

	public function getPath(access: Value, ?ignoreCase = true) {
		return Util._match(access,
			at((_.int - 1 => i) is Integer) => Option.fromNull(cast this.pick(i)),
			_ => None
		);
	}

	public function setPath(access: Value, newValue: Value, ?ignoreCase = true) {
		return Util._match(access,
			at((_.int - 1 => i) is Integer) => { // TODO: somehow typecheck against T
				this.poke(i, cast newValue);
				true;
			},
			_ => false
		);
	}
}