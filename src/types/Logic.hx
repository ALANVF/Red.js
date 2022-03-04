package types;

class Logic extends Value {
	public static final TRUE = new Logic(true);
	public static final FALSE = new Logic(false);

	public final cond: Bool;

	public static inline function fromCond(cond: Bool) {
		return if(cond) TRUE else FALSE;
	}

	function new(cond: Bool) {
		this.cond = cond;
	}

	override public function isTruthy() {
		return this.cond;
	}
}