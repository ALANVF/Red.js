package types.base;

abstract class _Name extends Value {
	public final name: std.String;

	public function new(name: std.String) this.name = name;

	public function equalsName(name: _Name) {
		return this.name.toLowerCase() == name.name.toLowerCase();
	}

	public function equalsString(str: std.String) {
		return this.name.toLowerCase() == str.toLowerCase();
	}
}