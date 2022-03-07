package types;

import haxe.ds.Option;
import types.base.Context;


private typedef Spec = {
	?code:  Int,
	type:   std.String,
	id:     std.String,
	?arg1:  Value,
	?arg2:  Value,
	?arg3:  Value,
	?near:  Iterable<Value>,
	?where: Value,
	?stack: Int
}

private typedef CreateSpec = {
	code:  Option<Int>,
	type:  std.String,
	id:    std.String,
	arg1:  Option<Value>,
	arg2:  Option<Value>,
	arg3:  Option<Value>,
	near:  Option<Iterable<Value>>,
	where: Option<Value>,
	stack: Option<Int>
}

class Error extends Object {
	public var type(get, never): std.String;
	function get_type() return cast(ctx.values[1], Word).name.toLowerCase();
	
	public var id(get, never): std.String;
	function get_id() return cast(ctx.values[2], Word).name.toLowerCase();

	override public function new(
		code:  Value,
		type:  Word,
		id:    Word,
		arg1:  Value,
		arg2:  Value,
		arg3:  Value,
		near:  Value,
		where: Value,
		stack: Value
	) {
		final ctx = new Context(
			[for(name in ["code", "type", "id", "arg1", "arg2", "arg3", "near", "where", "stack"]) new Word(name)],
			[code, type, id, arg1, arg2, arg3, near, where, stack]
		);

		super(ctx, 1);
	}

	static function _create(spec: CreateSpec) {
		return new Error(
			spec.code.map(c -> new Integer(c)).orElse(types.None.NONE),
			new Word(spec.type),
			new Word(spec.id),
			spec.arg1.orElse(types.None.NONE),
			spec.arg2.orElse(types.None.NONE),
			spec.arg3.orElse(types.None.NONE),
			spec.near.map(n -> new Block([for(v in n) v])).orElse(types.None.NONE),
			spec.where.orElse(types.None.NONE),
			spec.stack.map(s -> new Integer(s)).orElse(types.None.NONE)
		);
	}

	public static function create(spec: Spec) {
		return _create({
			code:  Option.fromNull(spec.code),
			type:  spec.type,
			id:    spec.id,
			arg1:  Option.fromNull(spec.arg1),
			arg2:  Option.fromNull(spec.arg2),
			arg3:  Option.fromNull(spec.arg3),
			near:  Option.fromNull(spec.near),
			where: Option.fromNull(spec.where),
			stack: Option.fromNull(spec.stack),
		});
	}

	public function description(): std.String {
		return '$type: $id';
	}

	public function isBreak() {
		return type == "throw" && id == "break";
	}

	public function isContinue() {
		return type == "throw" && id == "continue";
	}

	public function isReturn() {
		return type == "throw" && id == "return";
	}

	public function isThrow() {
		return type == "throw" && id == "throw";
	}

	public function isSpecial() {
		return type == "throw" && (
			id == "break" ||
			id == "continue" ||
			id == "return" ||
			id == "throw"
		);
	}
}