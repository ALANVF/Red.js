package types.base;

abstract class _Number extends Value {
	public abstract function asFloat(): StdTypes.Float;
	public abstract function asInt(): Int;
}