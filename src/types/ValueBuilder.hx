package types;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using util.ArrayTools;
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
		var vname = "K" + name;
		var dname = "D" + name;
		/*var valueKind = switch Context.getType("types.ValueKind") {
			case haxe.macro.Type.TEnum(_.get() => t, _): t;
			default: throw "error!";
		};
		var typeKind = switch Context.getType("types.TypeKind") {
			case haxe.macro.Type.TAbstract(_.get() => t, _) if(t.meta.has(":enum")): t;
			default: throw "error!";
		};*/

		//if(valueKind.names.contains(vname) && fields.every(f -> f.name != "get_KIND")) {
		//if(!cls.isAbstract) {
		if(!cls.isAbstract && name != "Context" && fields.every(f -> f.name != "get_KIND")) {
			fields.push({
				name: "get_KIND",
				pos: Context.currentPos(),
				access: [AOverride],
				kind: FFun({
					args: [],
					ret: TPath({
						pack: ["types"],
						name: "ValueKind"
					}),
					expr: cls.isAbstract ? null : macro return $p{["ValueKind", vname]}(this)
				})
			});
		}

		//var cases = typeKind.impl.get().statics.get().filter(f -> f.meta.has(":enum") && f.meta.has(":impl"));
		//if(cases.some(f -> f.name == dname) && fields.every(f -> f.name != "get_TYPE_KIND")) {
		//if(!cls.isAbstract) {
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
											args: fn.args.mapi((i, arg) -> ({
												name: args[i].name,
												opt: args[i].opt,
												type: Context.toComplexType(args[i].t),
												meta: arg.v.meta.get(),
												value: Context.getTypedExpr(arg.value)
											} : FunctionArg)),
											ret: Context.toComplexType(ret),
											/*Context.toComplexType(switch ret {
												case TInst(_.get().name => n) if(n == sc.name):
													Context.getLocalType();
												default:
													ret;
											})*/
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

					final f = @:privateAccess haxe.macro.TypeTools.toField(cfield);//@:privateAccess field.toField();
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

			return fields;

			//if(["_Block", "_SeriesOf", "_Path", "_String", "_Function", "Symbol"].contains(sc.name)) {
			if(sc.isAbstract && !cls.isAbstract && cls.name != "Context") {
				for(f in o.concat(sc.fields.get().filter(fl -> o.every(ov -> ov.name != fl.name)))) {
					final e = f.expr();
					final n = f.name;

					if(fields.find(f->f.name==n) != null || f.kind.match(FVar(_, _)) || !f.isPublic || f.isAbstract
					|| e == null || e.expr.match(TThrow(_)) || e.expr.match(TBlock(_[0] => {expr: TThrow(_), pos: _, t: _}))) {
						continue;
					}
					
					switch e.t {
						case TFun(args, ret) | TLazy(_() => TFun(args, ret)):
							switch ret {
								case TInst(_.get() => t, _) if(util.ArrayTools.equals(t.pack, sc.pack) && t.name == sc.name):
									final fn = switch e.expr {
										case TFunction(fn): fn;
										default: throw "error";
									};

									fields.push({
										name: f.name,
										pos: Context.currentPos(),
										access: [APublic, AOverride],
										kind: FFun({
											args: fn.args.mapi((i, a) -> {
												return {
													name: args[i].name,
													opt: args[i].opt,
													type: Context.toComplexType(args[i].t),
													meta: a.v.meta.get(),
													value: Context.getTypedExpr(a.value)/*switch a.v {
														case {extra: null | {expr: null}}: null;
														case {extra: {expr: expr}}: Context.getTypedExpr(expr);
													}*/
												};
											}),
											ret: Context.toComplexType(Context.getLocalType()),
											expr: macro {
												return cast super.$n($a{${[for(a in args) macro $i{a.name}]}});
											}
										})
									});
								default:
							}
						default:
					}
				}
			}
		}

		return fields;
	}
}