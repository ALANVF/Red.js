package types;

import types.base.IValue;
import haxe.ds.Option;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using util.ContextTools;

class Helpers {
	/*static macro function _getValueKindValue(vk: ExprOf<ValueKind>): ExprOf<Value> {
		switch Context.getType("types.ValueKind") {
			case TEnum(_.get() => t, _):
				var cases: Array<Case> = [];

				for(n => _ in t.constructs) {
					cases.push({
						values: [macro $i{n}(v)],
						expr: macro v
					});
				}

				return {
					expr: ESwitch(vk, cases, null),
					pos: Context.currentPos()
				};
			default: throw "error!";
		}
	}*/

	public static inline function getValue(vk: ValueKind):Value return vk.getParameters()[0]; //return _getValueKindValue(vk);

	public static macro function as<T: IValue>(value: ExprOf<IValue>, type: ExprOf<Class<T>>): ExprOf<T> {
		/*final ttype = {
			final t = util.MacroTools.typePathFromExpr(type);
			final t2 = Context.getType(t.value().join("."));
			final t3 = Context.toComplexType(t2);
			if(t3 != null) (t3 : ComplexType) else throw "error!";
		};*/

		final path = haxe.macro.ExprTools.toString(type).split(".");
		final ttype = TPath({
			pack: path.slice(0, path.length - 2),
			name: path[path.length - 1]
		});
		return macro cast($value, $ttype);
	}

	public static macro function is<T: IValue>(value: ExprOf<IValue>, type: ExprOf<Class<T>>): ExprOf<Option<T>> {
		/*final ttype = {
			final t = util.MacroTools.typePathFromExpr(type);
			final t2 = Context.getType(t.value().join("."));
			final t3 = Context.toComplexType(t2);
			if(t3 != null) (t3 : ComplexType) else throw "error!";
		};*/
		//final ttype = TPath(util.MacroTools.typePathFromExpr(type).value());
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