package types;

import haxe.ds.Option;

using util.OptionTools;
using util.ContextTools;
using util.NullTools;

class Helpers {
	static macro function _getValueKindValue(vk: haxe.macro.Expr.ExprOf<ValueKind>): haxe.macro.Expr.ExprOf<Value> {
		switch haxe.macro.Context.getType("types.ValueKind") {
			case haxe.macro.Type.TEnum(_.get() => t, _):
				var cases: Array<haxe.macro.Expr.Case> = [];

				for(n => _ in t.constructs) {
					cases.push({
						values: [macro $i{n}(v)],
						expr: macro v
					});
				}

				return {
					expr: haxe.macro.ExprDef.ESwitch(vk, cases, null),
					pos: haxe.macro.Context.currentPos()
				};
			default: throw "error!";
		}
	}

	public static inline function getValue(vk: ValueKind) return _getValueKindValue(vk);

	public static macro function as<T: Value>(value: haxe.macro.Expr.ExprOf<Value>, type: haxe.macro.Expr.ExprOf<Class<T>>): haxe.macro.Expr.ExprOf<T> {
		final ttype = {
			final t = util.MacroTools.typePathFromExpr(type);
			final t2 = haxe.macro.Context.getType(t.value().join("."));
			final t3 = haxe.macro.Context.toComplexType(t2);
			if(t3 != null) (t3 : haxe.macro.Expr.ComplexType) else throw "error!";
		};
		return macro cast($value, $ttype);
	}

	public static macro function is<T: Value>(value: haxe.macro.Expr.ExprOf<Value>, type: haxe.macro.Expr.ExprOf<Class<T>>): haxe.macro.Expr.ExprOf<Option<T>> {
		final ttype = {
			final t = util.MacroTools.typePathFromExpr(type);
			final t2 = haxe.macro.Context.getType(t.value().join("."));
			final t3 = haxe.macro.Context.toComplexType(t2);
			if(t3 != null) (t3 : haxe.macro.Expr.ComplexType) else throw "error!";
		};
		final tmp = haxe.macro.Context.newTempVar();
		return macro {
			final $tmp = $value;
			if(($i{tmp} is $type)) {
				Some(cast($value, $ttype));
			} else {
				None;
			}
		}
	}
}