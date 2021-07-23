package runtime;

//#if macro
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;
//#end

class ActionBuilder {
	// I hope that this name is self-explanatory
	public static macro function dumbFixForDCE() {
		return macro $a{(
			haxe.macro.TypeTools.getEnum(
				haxe.macro.ComplexTypeTools.toType((macro: types.Action.ActionFn))
			).names.map(name -> {
				return name.substring(1);
			}).map(name -> {
				var path = 'runtime.actions.$name';
				try {
					Context.getType(path);
				} catch(_: String) {
					return null;
				}
				return path;
			}).filter(path -> path != null).map(path -> path.split("."))
		).map(na -> macro $p{na})};
	}
	
	public static macro function build(?actionName: String): Array<Field> {
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

		final name = if(actionName != null) {
			(actionName : String);
		} else {
			"ACT_" + (
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
		final enumName = "A" + cls.name;
		
		final init = macro {
			runtime.actions.datatypes.ActionActions.MAPPINGS[$v{name}] = types.Action.ActionFn.$enumName(call);
		};

		if(!fields.some(f -> f.name == "__init__")) {
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
					{name: ":used", pos: Context.currentPos()},
					{name: ":directlyUsed", pos: Context.currentPos()},
					{name: ":keep", pos: Context.currentPos()}
				]
			});
		}

		return fields;
	}
}