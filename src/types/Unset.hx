package types;

class Unset extends Value {
	public static final UNSET = new Unset();

	function new() {}

	/*override function isTruthy(): Bool {
		return false;
	}*/

	override function isUnset() {
		return true;
	}
}