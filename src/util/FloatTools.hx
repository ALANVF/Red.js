package util;

@:publicFields
class FloatTools {
	static overload extern inline function toString(self: Float): String {
		return (untyped self).toString();
	}
	static overload extern inline function toString(self: Float, base: Int): String {
		return (untyped self).toString(base);
	}
}