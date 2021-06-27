package util;

/*using util.ContextTools;

import haxe.macro.Context;
import haxe.macro.Expr;*/

/*abstract NullTools<T>(Null<T>) from Null<T> to Null<T> {
	@:op(A!)
	public function shouldNotBeNull(): T {
		if(this == null) {
			throw "Error: Value was null!";
		} else {
			return this;
		}
	}
*/

class NullTools {
	/*public static macro function getOrElse<T>(
		value: ExprOf<Null<T>>,
		other: ExprOf<T>
	): ExprOf<T> {
		final tmp = Context.newTempVar();
		final type = ECheckType(
			(macro $i{tmp}),
			switch(Context.typeof(value)) {
				case TAbstract(_, [t]): Context.toComplexType(t);
				default: throw "error!";
			}
		);
		
		return macro {
			final $tmp = $value;
			if($i{tmp} != null) ${{expr: type, pos: Context.currentPos()}} else $other;
		}
	}*/

	/*public static macro function notNull<T>(
		value: ExprOf<Null<T>>
	): ExprOf<T> {
		final tmp = Context.newTempVar();
		final type = ECheckType(
			(macro $i{tmp}),
			switch(Context.typeof(value)) {
				case TAbstract(_, [t]): Context.toComplexType(t);
				default: throw "error!";
			}
		);
		
		return macro $b{[
			{macro final $tmp = $value;},
			macro if($i{tmp} != null) {
				${
					{expr: type, pos: Context.currentPos()}
				}
			} else {
				throw "Error: Value was null!";
			}
		]};
	}*/
	/*public static inline function notNull<T>(value: Null<T>): T {
		if(value == null) {
			throw "Value was null!";
		} else {
			return value;
		}
	}*/
}