package types.base;

import util.Set;

abstract class _Block extends _SeriesOf<Value> {
	public var newlines: Set<Int>;
	
	override public function new(values: Array<Value>, ?index: Int, ?newlines: Set<Int>) {
		super(values, index);
		this.newlines = newlines == null ? new Set() : newlines;
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

	override public function copy() {
		return this.cloneBlock(
			this.values.slice(this.index),
			0,
			this.newlines
				.filter(nl -> nl >= this.index)
				.map(nl -> nl - this.index)
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
}