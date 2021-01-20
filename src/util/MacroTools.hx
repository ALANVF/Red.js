package util;

import haxe.macro.Expr;
import haxe.ds.Option;


class MacroTools {
	public static function typePathFromExpr(expr: Expr): Option<Array<String>> {
		return switch expr.expr {
			case EConst(CIdent(name)): Some([name]);
			case EField(e, f): util.MacroTools.typePathFromExpr(e).map(path -> path.concat([f]));
			default: None;
		}
	}
}