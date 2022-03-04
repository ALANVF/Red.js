package types.base;

abstract class _Float extends _Number {
	public final float: StdTypes.Float;

	public function new(float: StdTypes.Float) this.float = float;
	
	public abstract function make(float: StdTypes.Float): _Float;

	public function asFloat() return float;
	public function asInt() return Std.int(float);
}