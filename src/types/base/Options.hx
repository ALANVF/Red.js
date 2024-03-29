package types.base;

import util.MacroTools;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using haxe.macro.TypeTools;

class Options {
	// TODO: clean up this code
	public static macro function defaultFor(typeExpr) {
		final type = Context.getType(MacroTools.typePathFromExpr(typeExpr).value().join("."));

		switch type {
			case TType(_.get().type => TAnonymous(_.get() => t), _) | TAnonymous(_.get() => t):
				final a = {
					expr: TObjectDecl(t.fields.map(f -> {
						return {
							name: f.name,
							expr: Context.typeExpr(switch f.type {
								case TAbstract(_.get().name => "Bool", _): macro false;
								case TAbstract(_.get().name => "Null", _): macro null;
								default: throw "error";
							})
						};
					})),
					pos: Context.currentPos(),
					t: type
				};

				final ctype = Context.toComplexType(type);
				return macro (${Context.getTypedExpr(a)} : $ctype);
			default:
				throw "error";
		}
	}

	public static macro function fromRefines(typeExpr, refines: ExprOf<Dict<std.String, Value>>) {
		final type = Context.getType(MacroTools.typePathFromExpr(typeExpr).value().join("."));

		switch type {
			case TType(_.get().type => TAnonymous(_.get() => t), _) | TAnonymous(_.get() => t):
				final fields = [];
			
				for(field in t.fields) {
					var name = field.name.startsWith("_") ? field.name.substr(1) : field.name;
					name = ~/-([a-z])/g.map(name, r -> r.matched(1).toUpperCase());
					
					fields.push({
						name: field.name,
						expr: switch field.type {
							case TAbstract(_.get().name => "Bool", _): Context.typeExpr(macro $refines[$v{name}] != null); // TODO: why is this needed lol? I thought it was already handled somewhere else
							case TAbstract(_.get().name => "Null", [param]):
								Context.typeExpr(macro {
									switch $refines[$v{name}] {
										case null: null;
										case args: ${
											switch param {
												case TAnonymous(_.get() => p):
													final obj = [];
													for(i => f in p.fields) {
														final cft = {
															final t = Context.toComplexType(f.type);
															if(t != null) (t : ComplexType) else throw "error!";
														};
														final expr = if(f.name == "Value") {
															macro args[$v{i}];
														} else {
															macro {
																//if(Std.isOfType(args[$v{i}], $p{f.type.toString().split(".")})) {
																if(${{
																	expr: EIs(
																		(macro args[$v{i}]),
																		f.type.toComplexType()
																	),
																	pos: Context.currentPos()
																}}) {
																	cast(args[$v{i}], $cft);
																} else {
																	throw "type error!";
																}
															};
														};
														final name = ~/-([a-z])/g.map(f.name, r -> r.matched(1).toUpperCase());
														obj.push({name: name, expr: Context.typeExpr(expr)});
													}
													Context.getTypedExpr({
														expr: TObjectDecl(obj),
														pos: Context.currentPos(),
														t: param
													});
												default:
													throw "error!";
											}
										};
									}
								});
							default:
								throw "error";
						}
					});
				}

				return Context.getTypedExpr({
					expr: TObjectDecl(fields),
					pos: Context.currentPos(),
					t: type
				});
			default:
				throw "error";
		}
	}
}