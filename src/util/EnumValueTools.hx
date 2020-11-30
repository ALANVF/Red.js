package util;

import haxe.macro.Context;
import haxe.macro.Expr;

class EnumValueTools {
	public static macro function extract<T: EnumValue>(value: ExprOf<T>, pattern, expr, ?otherwise) {
		return macro {
			switch($value) {
				case $pattern: $expr;
				default: ${otherwise != null ? otherwise : macro throw "Error!"};
			}
		}
	}

	public static macro function attempt<T: EnumValue>(value: ExprOf<T>, pattern, expr, ?otherwise) {
		return macro {
			switch($value) {
				case $pattern: $expr;
				default: ${otherwise != null ? otherwise : macro $b{[]}};
			}
		}
	}
}