package runtime;

//#if macro
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;
//#end

class NativeBuilder {
	// I hope that this name is self-explanatory
	public static macro function dumbFixForDCE() {
		return macro $a{(
			haxe.macro.TypeTools.getEnum(
				haxe.macro.ComplexTypeTools.toType((macro: types.Native.NativeFn))
			).names.map(name -> {
				return name.substring(1);
			}).map(name -> {
				var path = 'runtime.natives.$name';
				try {
					Context.getType(path);
				} catch(_: String) try {
					Context.getType(path = 'runtime.natives.Compare.$name');
				} catch(_: String) {
					return null;
				}
				return path;
			}).filter(path -> path != null).map(path -> path.split("."))
		).map(na -> macro $p{na})};
	}
	
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
			"NAT_" + (
				~/_q$/g.replace(
					~/([a-z])([A-Z])/g.replace(
						cls.name,
						"$1_$2"
					),
					"?"
				)
			).toUpperCase();
		};

		final callFn = switch fields.findMap(f -> switch f {
			case {name: "call", kind: FFun(fn), access: acc} if(acc != null && acc.contains(AStatic)):
				if(!f.meta.some(m -> m.name == ":keep")) f.meta.push({name: ":keep", pos: f.pos});
				fn;
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
				}),
				meta: [
					{
						name: ":used",
						pos: Context.currentPos()
					},
					{
						name: ":directlyUsed",
						pos: Context.currentPos()
					},
					{
						name: ":keep",
						pos: Context.currentPos()
					}
				]
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