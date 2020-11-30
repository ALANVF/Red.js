package types;

import types.base.IValue;
import types.base.IDatatype;
import haxe.macro.Context;

using util.ArrayTools;
using Lambda;

@:noCompletion
@:noDoc
@:noImportGlobal
class _ValueBuilder {
#if macro
	public static function build(): Array<haxe.macro.Expr.Field> {
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
		var valueKind = switch Context.getType("types.ValueKind") {
			case haxe.macro.Type.TEnum(_.get() => t, _): t;
			default: throw "error!";
		};
		var typeKind = switch Context.getType("types.TypeKind") {
			case haxe.macro.Type.TAbstract(_.get() => t, _) if(t.meta.has(":enum")): t;
			default: throw "error!";
		};

		if(valueKind.names.contains(vname) && fields.every(f -> f.name != "get_KIND")) {
			fields.push({
				name: "get_KIND",
				pos: Context.currentPos(),
				access: [AOverride],
				kind: FFun({
					args: [],
					ret: null,
					expr: macro return $p{["ValueKind", vname]}(this)
				})
			});
		}

		var cases = typeKind.impl.get().statics.get().filter(f -> f.meta.has(":enum") && f.meta.has(":impl"));
		if(cases.some(f -> f.name == dname) && fields.every(f -> f.name != "get_TYPE_KIND")) {
			fields.push({
				name: "get_TYPE_KIND",
				pos: Context.currentPos(),
				access: [AOverride],
				kind: FFun({
					args: [],
					ret: null,
					expr: macro return $p{["TypeKind", dname]}
				})
			});
		}

		if(cls.superClass != null) {
			final sc = cls.superClass.t.get();
			final o = sc.overrides.map(ov -> ov.get());
			
			if(["_Block", "_SeriesOf", "_Path", "_String", "_Function", "Symbol"].contains(sc.name)) {
				for(f in o.concat(sc.fields.get().filter(fl -> o.every(ov -> ov.name != fl.name)))) {
					final e = f.expr();
					final n = f.name;

					if(fields.find(f->f.name==n) != null || f.kind.match(FVar(_, _)) || !f.isPublic
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
													value: switch a.v {
														case {extra: null | {expr: null}}: null;
														case {extra: {expr: expr}}: Context.getTypedExpr(expr);
													}
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
#end
}

#if !macro
@:autoBuild(types._ValueBuilder.build())
#end
class Value implements IValue {
	public var KIND(get, never): ValueKind;
	function get_KIND(): ValueKind {
		throw "Must be implemented in subclasses!";
	}

	public var TYPE_KIND(get, never): TypeKind;
	private function get_TYPE_KIND(): TypeKind {
		throw "Must be implemented in subclasses!";
	}

	public function isTruthy() {
		return true;
	}
	
	public inline function isA(type: IDatatype) {
		return type.matchesTypeOfValue(this);
	}
}