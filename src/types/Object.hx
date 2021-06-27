package types;

import types.base.ISetPath;
import types.base.IGetPath;
import types.base.Context;
import haxe.ds.Option;

class Object extends Value implements IGetPath implements ISetPath {
	public static var maxID: Int = 0;

	public final ctx: Context;
	public final classID: Int;

	public function new(?ctx: Context, ?classID: Int) {
		this.ctx = if(ctx == null) new Context() else new Context(ctx.symbols, ctx.values);
		this.classID = if(classID == null) ++maxID else classID;
	}

	public static inline function fromObject(obj: Object) {
		return new Object(obj.ctx, obj.classID);
	}

	public function getPath(access: Value, ?ignoreCase = true) {
		return Util._match(access,
			at({name: n} is Word, when(ctx.contains(n, ignoreCase))) => Some(ctx.get(n, ignoreCase)),
			_ => None
		);
	}

	public function setPath(access: Value, newValue: Value, ?ignoreCase = true) {
		return Util._match(access,
			at({name: n} is Word, when(ctx.contains(n, ignoreCase))) => {
				ctx.set(n, newValue, ignoreCase);
				true;
			},
			_ => false
		);
	}

	public function get(word, ?ignoreCase = true) {
		return ctx.get(word, ignoreCase);
	}

	public function set(word, newValue, ?ignoreCase = true) {
		return ctx.set(word, newValue, ignoreCase);
	}
}