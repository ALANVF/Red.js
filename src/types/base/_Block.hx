package types.base;

import util.Set;

abstract class _Block extends _SeriesOf<Value> {
	public var newlines: Null<Set<Int>>;
	
	override public function new(values: Array<Value>, ?index: Int, ?newlines: Set<Int>) {
		super(values, index);
		this.newlines = newlines;
	}

	abstract function cloneBlock(values: Array<Value>, ?index: Int, ?newlines: Set<Int>): _Block; // ugh, can't wait for polymorphic `this` types
	
	function clone(values, ?index) {
		return this.cloneBlock(values, index);
	}

	override public function at(index: Int) {
		return this.cloneBlock(
			this.values,
			Std.int(
				Math.max(
					0,
					Math.min(
						this.absLength,
						this.index + (index <= 0 ? index : index - 1)
					)
				)
			),
			this.newlines
		);
	}

	override public function skip(index: Int) {
		return this.cloneBlock(
			this.values,
			Std.int(
				Math.max(
					0,
					Math.min(
						this.absLength,
						this.index + index
					)
				)
			),
			this.newlines
		);
	}

	override public function skipHead(index: Int) {
		return this.cloneBlock(
			this.values,
			Std.int(
				Math.max(
					0,
					Math.min(
						this.absLength,
						index
					)
				)
			),
			this.newlines
		);
	}

	override public function fastSkipHead(index: Int) {
		return this.cloneBlock(
			this.values,
			index,
			this.newlines
		);
	}

	override public function copy() {
		return this.cloneBlock(
			this.values.slice(this.index),
			0,
			this.newlines._and(n => n
				.filter(nl -> nl >= this.index)
				.map(nl -> nl - this.index)
			)
		);
	}

	override public function head() {
		return this.cloneBlock(
			this.values,
			0,
			this.newlines
		);
	}

	override public function tail() {
		return this.cloneBlock(
			this.values,
			this.absLength,
			this.newlines
		);
	}

	public function addNewline(index: Int) {
		newlines._andOr(
			n => n.add(index),
			newlines = new Set([index])
		);
	}

	public function removeNewline(index: Int) {
		newlines._and(n => n.remove(index));
	}

	public function hasNewline(index: Int) {
		return newlines._andOr(
			n => n.has(index),
			false
		);
	}
}