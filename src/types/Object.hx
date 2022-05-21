package types;

import types.base.ISetPath;
import types.base.IGetPath;
import types.base.Context;
import haxe.ds.Option;

class Object extends Value implements IGetPath implements ISetPath {
	public static var maxID: Int = 0;

	public final ctx: Context;
	public var classID: Int;

	public function new(?ctx: Context, ?classID: Int, dontCopy: Bool = false) {
		this.ctx = ctx._andOr(
			ctx => if(dontCopy) ctx else new Context(ctx.symbols, ctx.values),
			new Context()
		);
		this.ctx.value = this;
		this.classID = if(classID == null) ++maxID else classID;
	}

	public static inline function fromObject(obj: Object) {
		return new Object(obj.ctx, obj.classID);
	}

	public function getPath(access: Value, ?ignoreCase = true) {
		return Util._match(access,
			at({symbol: {name: n}} is Word, when(ctx.contains(n, ignoreCase))) => Some(ctx.get(n, ignoreCase)),
			_ => None
		);
	}

	public function setPath(access: Value, newValue: Value, ?ignoreCase = true) {
		return Util._match(access,
			at({symbol: {name: n}} is Word, when(ctx.contains(n, ignoreCase))) => {
				ctx.set(n, newValue, ignoreCase);
				true;
			},
			_ => false
		);
	}

	public inline function get(word, ignoreCase = true) {
		return ctx.get(word, ignoreCase);
	}

	public inline function set(word, newValue, ignoreCase = true) {
		return ctx.set(word, newValue, ignoreCase);
	}

	public inline function add(word, value, ignoreCase = true) {
		return ctx.add(word, value, ignoreCase);
	}

	public inline function addOrSet(word, value, ignoreCase = true) {
		return ctx.addOrSet(word, value, ignoreCase);
	}

	public inline function addOrSetWord(word, value, ignoreCase = true) {
		return ctx.addOrSetWord(word, value, ignoreCase);
	}
}