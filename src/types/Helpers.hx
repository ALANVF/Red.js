package types;

import types.base.IValue;
import haxe.ds.Option;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using util.ContextTools;

class Helpers {
	public static inline function getValue(vk: ValueKind):Value return vk.getParameters()[0];

	public static macro function as<T: IValue>(value: ExprOf<IValue>, type: ExprOf<Class<T>>): ExprOf<T> {
		final path = haxe.macro.ExprTools.toString(type).split(".");
		final ttype = TPath({
			pack: path.slice(0, path.length - 2),
			name: path[path.length - 1]
		});
		return macro cast($value, $ttype);
	}

	public static macro function is<T: IValue>(value: ExprOf<IValue>, type: ExprOf<Class<T>>): ExprOf<Option<T>> {
		final path = haxe.macro.ExprTools.toString(type).split(".");
		final ttype = TPath({
			pack: path.slice(0, path.length - 2),
			name: path[path.length - 1]
		});
		final tmp = Context.newTempVar();
		return macro {
			final $tmp = $value;
			if(Std.isOfType($i{tmp}, ${type})) {
				Some(cast($value, $ttype));
			} else {
				None;
			}
		}
	}
}