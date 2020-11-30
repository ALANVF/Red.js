package types.base;

import haxe.ds.Option;
import haxe.macro.Type;
import haxe.macro.Type.TypedExprDef;
import haxe.macro.Expr;
import haxe.macro.Context;

using util.OptionTools;

class Options {
	static function typePathFromExpr(expr: Expr): Option<Array<std.String>> {
		return switch expr.expr {
			case haxe.macro.ExprDef.EConst(haxe.macro.Constant.CIdent(name)): Some([name]);
			case haxe.macro.ExprDef.EField(e, f): typePathFromExpr(e).map(path -> path.concat([f]));
			default: None;
		}
	}

	// TODO: clean up this code
	public static macro function defaultFor(typeExpr: Expr) {
		final type = Context.getType(typePathFromExpr(typeExpr).value().join("."));

		switch type {
			case Type.TType(_.get().type => haxe.macro.Type.TAnonymous(_.get() => t), _) | haxe.macro.Type.TAnonymous(_.get() => t):
				final a = {
					expr: TypedExprDef.TObjectDecl(t.fields.map(f -> {
						return {
							name: f.name,
							expr: switch f.type {
								case TAbstract(_.get().name => "Bool", _):
									{
										expr: TypedExprDef.TConst(TConstant.TBool(false)),
										pos: Context.currentPos(),
										t: f.type
									};
								case TEnum(_.get() => t, _) if(t.name == "Option"):
									{
										expr: TypedExprDef.TIdent("None"),
										pos: Context.currentPos(),
										t: f.type
									};
								default:
									throw "error";
							}
						};
					})),
					pos: Context.currentPos(),
					t: type
				};

				return Context.getTypedExpr(a);
			default:
				throw "error";
		}
	}
}