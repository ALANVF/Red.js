package types.base;

abstract class _AnyWord extends _Word {
	public abstract function copyWith(symbol: Symbol): _AnyWord;

	public abstract function copyIn(context: Context, index: Int): _AnyWord;

	public abstract function copyFrom(word: _Word): _AnyWord;
}