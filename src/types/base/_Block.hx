package types.base;

import util.Set;

abstract class _Block extends _BlockLike {
	public var newlines: Null<Set<Int>>;
	
	override public function new(values: Array<Value>, ?index: Int, ?newlines: Set<Int>) {
		super(values, index);
		this.newlines = newlines;
	}

	abstract function cloneBlock(values: Array<Value>, ?index: Int, ?newlines: Set<Int>): _Block; // ugh, can't wait for polymorphic `this` types
	
	function clone(values, ?index) {
		return this.cloneBlock(values, index, this.newlines);
	}

	override public function at(index: Int) {
		return this.cloneBlock(
			this.values,
			(this.index + (index <= 0 ? index : index - 1)).clamp(
				0,
				this.absLength
			),
			this.newlines
		);
	}

	override public function skip(index: Int) {
		return this.cloneBlock(
			this.values,
			(this.index + index).clamp(
				0,
				this.absLength
			),
			this.newlines
		);
	}

	override public function skipHead(index: Int) {
		return this.cloneBlock(
			this.values,
			index.clamp(
				0,
				this.absLength
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
			this.newlines
				?.filter(nl -> nl >= this.index)
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

	public function addNewline(index: Int) {
		newlines._andOr(
			n => n.add(index),
			newlines = new Set([index])
		);
	}

	public function removeNewline(index: Int) {
		newlines?.remove(index);
	}

	public inline function setNewline(index: Int, cond: Bool) {
		if(cond) addNewline(index) else removeNewline(index);
	}

	public function hasNewline(index: Int) {
		return newlines?.has(index) ?? false;
	}
}