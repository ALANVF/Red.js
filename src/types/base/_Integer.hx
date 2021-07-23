package types.base;

abstract class _Integer extends _Number {
	public final int: Int;

	public function new(int: Int) this.int = int;
	
	public abstract function make(value: Int): _Integer;
}