package util;

@:publicFields
@:structInit
private class _Series<T> {
	final values: Array<T>;
	final offset: Int;

	inline function new(values: Array<T>, offset: Int) {
		this.values = values;
		this.offset = offset;
	}
}

@:forward
@:forward.new
abstract Series<T>(_Series<T>) from _Series<T> {
	public var length(get, never): Int;
	inline function get_length() {
		return this.values.length - this.offset;
	}


	@:from
	static inline function fromSeriesOf<T: types.Value>(series: types.base._SeriesOf<T>) {
		return new Series(series.values, series.index);
	}

	@:from
	static inline function fromArray<T>(array: Array<T>) {
		return new Series(array, 0);
	}


	@:op(A + B)
	public inline function skip(by: Int) {
		return inline new Series(this.values, this.offset + by);
	}

	public inline function next() return skip(1);

	@:op(A++)
	inline function incrPost(): Series<T> {
		final ret = this;
		this = inline new _Series(this.values, this.offset + 1);
		return ret;
	}

	@:op(++A)
	inline function incrPre(): Series<T> {
		return this = inline new _Series(this.values, this.offset + 1);
	}

	@:arrayAccess
	inline function get(index: Int) {
		return this.values[this.offset + index];
	}

	@:arrayAccess
	inline function set(index: Int, value: T) {
		this.values[this.offset + index] = value;
	}

	public inline function isHead() return this.offset == 0;

	public overload extern inline function isTail() return this.offset >= this.values.length;
	public overload extern inline function isTail(after: Int) return this.offset + after >= this.values.length;

	public overload extern inline function isNotTail() return this.offset < this.values.length;
	public overload extern inline function isNotTail(after: Int) return this.offset + after < this.values.length;

	public overload extern inline function isEnd() return this.offset == this.values.length - 1;
	public overload extern inline function isEnd(after: Int) return this.offset + after == this.values.length - 1;
}