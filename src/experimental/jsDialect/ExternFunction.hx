package experimental.jsDialect;

@:structInit class ExternFunction {
	public var path: Array<String>;
	public var args: Array<TypeKind>;
	public var ret: TypeKind;
	public var varargs = false;

	public function new(path: Array<String>, args: Array<TypeKind>, ret: TypeKind, varargs = false) {
		this.path = path;
		this.args = args;
		this.ret = ret;
		this.varargs = varargs;
	}
}