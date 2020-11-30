package types.base;

using util.NullTools;

import util.Set;

class _Block extends _SeriesOf<Value> {
	public var newlines: Set<Int>;
	
	override public function new(values: Array<Value>, ?index: Int, ?newlines: Set<Int>) {
		super(values, index);
		this.newlines = newlines.getOrElse(new Set());
	}

	function cloneBlock(values: Array<Value>, ?index: Int, ?newlines: Set<Int>): _Block { // ugh, can't wait for polymorphic `this` types
		throw "must be implemented by subclasses!";
	}
	
	override public function at(index: Int) {
		return this.cloneBlock(
			this.values,
			Std.int(
				Math.min(
					0,
					Math.max(
						this.absLength - 1,
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
				Math.min(
					0,
					Math.max(
						this.absLength - 1,
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
			this.absLength - 1,
			this.newlines
		);
	}
}