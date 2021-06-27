package types;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;

@:noCompletion
class ValueBuilder {
	public static macro function build(): Array<Field> {
		var cls = switch Context.getLocalType() {
			case TInst(_.get() => t, _): t;
			default: throw "error!";
		};
		
		if(cls.meta.has(":processed")) {
			return null;
		} else {
			cls.meta.add(":processed", [], cls.pos);
		}

		var fields = Context.getBuildFields();
		var name = cls.name;
		var dname = "D" + name;

		if(!cls.isAbstract && name != "Context" && fields.every(f -> f.name != "get_TYPE_KIND")) {
			fields.push({
				name: "get_TYPE_KIND",
				pos: Context.currentPos(),
				access: [AOverride],
				kind: FFun({
					args: [],
					ret: TPath({
						pack: ["types"],
						name: "TypeKind"
					}),
					expr: cls.isAbstract ? null : macro return $p{["TypeKind", dname]}
				})
			});
		}

		if(cls.superClass != null) {
			final sc = cls.superClass.t.get();
			final o = sc.overrides.map(ov -> ov.get());

			if(cls.isAbstract && sc.isAbstract) {
				for(f in sc.fields.get()) switch f {
					case {name: name, kind: FMethod(m), isAbstract: true} if(fields.find(f2 -> f2.name == name) == null):
						fields.push({
							name: f.name,
							access: {
								final access: Array<Access> = [AAbstract];

								switch m {
									case MethNormal:
									case MethInline: access.push(AInline);
									case MethDynamic: access.push(ADynamic);
									case MethMacro: access.push(AMacro);
								}

								access.push(f.isPublic ? APublic : APrivate);
								if(f.isExtern) access.push(AExtern);
								if(f.isFinal) access.push(AFinal);
								if(f.overloads.get().length > 0) access.push(AOverload);

								access;
							},
							kind: FFun({
								final expr = f.expr();

								if(expr == null) {
									continue;
								}

								switch expr.t {
									case TFun(args, ret) | TLazy(_() => TFun(args, ret)):
										final fn = switch expr.expr {
											case TFunction(fn): fn;
											default: throw "error";
										};

										{
											args: fn.args.mapi((i, arg) -> {
												name: args[i].name,
												opt: args[i].opt,
												type: Context.toComplexType(args[i].t),
												meta: arg.v.meta.get(),
												value: Context.getTypedExpr(arg.value)
											}),
											ret: Context.toComplexType(ret),
										};

									default: throw "Error!";
								}
							}),
							pos: Context.currentPos()
						});
					
					default:
				}
			}
			
			if(sc.name != "Value") {
				for(field in sc.fields.get()) if(
					!field.isAbstract
					&& field.kind.match(FMethod(_))
					&& fields.find(f -> f.name == field.name) == null
				) {
					final cfield = Reflect.copy(field);
					
					final expr = cfield.expr();

					if(expr == null) continue;

					cfield.type = expr.t;

					if(!cfield.type.match(TFun(_, _))) continue;

					final f = @:privateAccess haxe.macro.TypeTools.toField(cfield);
					switch f {
						case {kind: FFun(fn = {ret: TPath(p)})} if(p.name == sc.name && (switch p.pack {
							case [] | ["types"] | ["types", "base"]: true;
							default: false;
						})):
							final n = f.name;
							final t = Context.toComplexType(Context.getLocalType());
							fields.push({
								name: f.name,
								access: f.access == null ? [] : (f.access.contains(AOverride) ? f.access : [AOverride].concat(f.access)),
								kind: FFun({
									args: fn.args,
									ret: Context.toComplexType(Context.getLocalType()),
									expr: macro return cast(super.$n($a{fn.args.map(a -> macro $i{a.name})}), $t),
									params: fn.params
								}),
								pos: Context.currentPos()
							});
						
						default:
					}
				}
			}
		}

		return fields;
	}
}