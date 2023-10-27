import haxe.macro.Expr.ComplexType;
import haxe.macro.Context;

@:publicFields
class Macros {
	static macro function processSetVirtual(bs, bit) {
		return macro if(isNot) {
			if(isVirtualBit($bs, $bit)) return 1;
		} else {
			boundCheck($bs, $bit);
		};
	}

	static macro function processClearVirtual(bs, bit) {
		return macro if(isNot) {
			boundCheck($bs, $bit);
		} else {
			if(isVirtualBit($bs, $bit)) return 0;
		}
	}

	static macro function getBuild() {
		final date = Date.now();
		final res = '${date.getFullYear()}.${date.getMonth() + 1}.${date.getDate()}';
		return macro $v{res};
	}

	static macro function addFields(obj, fields) {
		var objType = Context.typeof(obj);
		var fieldsCType = Context.toComplexType(Context.typeof(fields));
		var resType = switch [objType, fieldsCType] {
			case [TType(_.get() => objTypedef, _), TAnonymous(newFields)]:
				ComplexType.TExtend([{
					pack: objTypedef.pack,
					name: objTypedef.name
				}], newFields);
			
			default:
				throw "bad";
		}

		var res = "{{...{0}";
		var resValues = [obj];
		var c = 1;
		
		switch fields.expr {
			case EObjectDecl(fs):
				for(f in fs) {
					res += ', ${f.field}: {$c}';
					resValues.push(f.expr);
					c++;
				}

			default:
				throw "bad";
		}

		res += "}}";

		resValues.unshift(macro $v{res});
		
		return macro (cast js.Syntax.code($a{resValues}) : $resType);
	}

	static macro function swap(a, b) {
		return macro js.Syntax.code("[{0}, {1}] = [{1}, {0}]", $a, $b);
	}

	/*static extern inline overload macro function bigInt(n: Int): haxe.macro.Expr.ExprOf<util.BigInt> {
		return macro js.Syntax.code("{0}n", $v{n});
	}
	static extern inline overload macro function bigInt(s: String): haxe.macro.Expr.ExprOf<util.BigInt> {
		return macro js.Syntax.plainCode($v{s + "n"});
	}*/

	static macro function bigInt(v): haxe.macro.Expr.ExprOf<util.BigInt> {
		switch v.expr {
			case EConst(CInt(n)): return macro (js.Syntax.plainCode($v{n + "n"}) : util.BigInt);
			case EConst(CString(s)): return macro (js.Syntax.plainCode($v{s + "n"}) : util.BigInt);
			default: throw "bad";
		}
	}
}