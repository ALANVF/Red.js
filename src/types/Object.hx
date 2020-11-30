package types;

import types.base.ISetPath;
import types.base.IGetPath;
import types.base.Context;
import haxe.ds.Option;

using util.NullTools;

class Object extends Value implements IGetPath implements ISetPath {
	public static var maxID: Int = 0;

	public final ctx: Context;
	public final id: Int;

	public function new(?ctx: Context, ?id: Int) {
		this.ctx = if(ctx == null) new Context() else new Context(ctx.symbols, ctx.values);
		this.id = id.getOrElse(++maxID);
	}

	public static inline function fromObject(obj: Object) {
		return new Object(obj.ctx, obj.id);
	}

	public function getPath(access: Value, ?ignoreCase = true) {
		return switch access.KIND {
			case KWord(_.name => n) if(ctx.contains(n, ignoreCase)): Some(ctx.get(n, ignoreCase));
			default: None;
		};
	}

	public function setPath(access: Value, newValue: Value, ?ignoreCase = true) {
		return switch access.KIND {
			case KWord(_.name => n) if(ctx.contains(n, ignoreCase)):
				ctx.set(n, newValue, ignoreCase);
				true;
			default:
				false;
		}
	}
}