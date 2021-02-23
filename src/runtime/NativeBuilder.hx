package runtime;

//#if macro
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;

using util.ArrayTools;
//#end

class NativeBuilder {
//#if macro
	//public static var natives: Array<{name: String, nativeName: String, call: Function}> = [];

	public static macro function build(?nativeName: String): Array<Field> {
		final cls = switch Context.getLocalType() {
			case TInst(_.get() => t, _): t;
			default: throw "error!";
		};
		
		if(cls.meta.has(":processed")) {
			return null;
		} else {
			cls.meta.add(":processed", [], cls.pos);
		}

		final fields = Context.getBuildFields();

		final name = if(nativeName != null) {
			(nativeName : String);
		} else {
			"NAT_" + ~/([a-z])([A-Z])/g.replace(cls.name, "$1_$2").toUpperCase();
		};

		final callFn = switch fields.findMap(f -> switch f {
			case {name: "call", kind: FFun(fn), access: acc} if(acc != null && acc.contains(AStatic)): fn;
			default: null;
		}) {
			case null: trace("??? " + cls.name); return null;
			case fn: (fn : Function);
		};

		final className = cls.name;
		final enumName = "N" + cls.name;

		final init = macro {
			runtime.actions.datatypes.NativeActions.MAPPINGS[$v{name}] = types.Native.NativeFn.$enumName(call);
		};

		if(fields.find(f -> f.name == "__init__") == null) {
			fields.push({
				name: "__init__",
				access: [AStatic],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					ret: null,
					expr: init
				})
			});
		}

		/*if(natives.some(n -> n.name == cls.name)) {
			trace(":thonk:");
		} else {
			natives.push({name: cls.name, nativeName: name, call: callFn});
			//trace(natives);
		}

		var finished = true;
		for(type in Context.getModule("runtime.natives")) {
			switch type {
				case TInst(_.get() => t, _):
					if(t.statics.get().some(f -> f.name == "call" && f.kind.match(FMethod(MethNormal)))) {
						if(!t.meta.has(":processed")) {
							finished = false;
							break;
						}
					}
				default:
			}
		}
		if(finished) {
			genMappings
		}*/

		return fields;
	}

	/*public static macro function genMappings() {
		
	}*/
//#end
}