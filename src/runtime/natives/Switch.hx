package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.*;
import types.TypeKind;
import js.Syntax.code as emit;

@:build(runtime.NativeBuilder.build())
class Switch {
	public static final defaultOptions = Options.defaultFor(NSwitchOptions);

	public static function call(value: Value, cases: Block, options: NSwitchOptions): Value {
		final len = cases.length;
		final kind = value.TYPE_KIND;

		var i = 0;
		while(i < len) {
			var v = cases.fastPick(untyped i); // `untyped` prevents `i` from being inlined

			// Haxe doesn't allow normal expressions as patterns, so we generate JS to bypass that restriction :/
			emit("switch({0}) { //", v.TYPE_KIND);
				emit("case {0}: break", DBlock);
				emit("case {0}: //", kind);
					if(Compare.Equal_q.call(value, v).cond) {
						// Bypass DCE
						emit("/*");
						var blk = null;
						emit("*/ let blk");

						// Apparently Haxe doesn't generate do...while loops, nor treat assignment as an expression
						emit("do {");
							if(++i >= len) return None.NONE;
						emit("} while{0}", (emit("({0} = {1})", blk, cases.fastPick(i)) : Value).TYPE_KIND != DBlock);
						
						return Do.evalValues((blk : Block));
					}
			emit("}");
			i++;
		}

		return switch options._default {
			case {_case: _case}: Do.evalValues(_case);
			case null: None.NONE;
		}
	}
}