#if (php || neko || cpp || macro || java || lua || python || hl)
	import sys.io.File;
#end

import haxe.ds.Option;
using util.OptionTools;

using StringTools;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Expr.ComplexType;
import haxe.macro.ExprTools;
import haxe.macro.TypeTools;

@:publicFields
class Util {
	static function mustParseInt(str: String) {
		//return Std.parseInt(str).nonNull();
		switch Std.parseInt(str) {
			case null: throw "Value was null!";
			case int: return (int : Int);
		}
	}

	@:noUsing
	static function readFile(path: String): String {
#if (php || neko || cpp || macro || java || lua || python || hl)
		return File.getContent(path);
#elseif js
		try {
			return js.Lib.require("fs").readFileSync(path).toString();
		} catch(e: Dynamic) {
			js.Lib.rethrow();
			return "";
		}
#else
		throw "todo!";
#end
	}

#if js
	@:noUsing
	static inline function encodeURIComponent(str: String): String {
		return js.Syntax.code("encodeURIComponent({0})", str);
	}

	@:noUsing
	static inline function decodeURIComponent(str: String): String {
		return js.Syntax.code("decodeURIComponent({0})", str);
	}
#end

	private static function _pretty(value: Any, indent: Int): String {
		final thisLevel = "".lpad("\t", indent);
		final nextLevel = "".lpad("\t", indent + 1);
		
		return if(value is Array) {
			final array = (value : Array<Any>);

			if(array.length == 0) {
				"[]";
			} else {
				var out = new StringBuf();
				
				out.add("[\n");
				
				for(i in 0...array.length) {
					out.add(nextLevel);
					out.add(_pretty(array[i], indent + 1));
					if(i < array.length - 1) {
						out.add(",");
					}
					out.add("\n");
				}

				out.add('$thisLevel]');

				out.toString();
			}
		} else if(Reflect.isEnumValue(value)) {
			final value = (value : EnumValue);
			final name = value.getName();

			switch value.getParameters() {
				case []: name;
				case [param]: '$name(${_pretty(param, indent)})';
				case params: '$name(\n' + params.map(param -> nextLevel + _pretty(param, indent + 1)).join(",\n") + '\n$thisLevel)';
			}
		} else {
			Std.string(value);
		}
	}

	@:noUsing
	static function pretty(value: Any): String {
		return _pretty(value, 0);
	}

	@:noUsing
	static macro function assert(expr) {
		return macro {
			if(!($expr)) {
				throw 'Assertion failed: ${ExprTools.toString(expr)}';
			}
		};
	}

	@:noUsing
	static macro function ifMatch(value, pattern, expr, ?otherwise) {
		return macro {
			switch($value) {
				case $pattern: $expr;
				default: ${otherwise != null ? otherwise : macro $b{[]}};
			}
		};
	}
	
	@:noUsing
	static macro function get(value, pattern, expr) {
		return macro {
			switch($value) {
				case $pattern: $expr;
			}
		}
	}

	@:noUsing
	static macro function extract(value, pattern, expr) {
		return macro {
			switch($value) {
				case $pattern: $expr;
				default: throw "Match error!";
			}
		};
	}

	@:noUsing
	static macro function detuple(lhs, rhs) {
		final rhsT = Context.follow(Context.typeof(rhs));
		switch rhsT {
			case TAbstract(_.get() => {pack: ["util"], name: "Tuple2"}, [ta, tb]):
				final cta = Context.toComplexType(ta);
				final ctb = Context.toComplexType(tb);

				switch lhs {
					case macro @var [${a = macro $i{ia}}, ${b = macro $i{ib}}]:
						return macro @:mergeBlock {
							js.Syntax.code("/*");
							var
								$ia: $cta = js.Syntax.code(""),
								$ib: $ctb = js.Syntax.code("");
							js.Syntax.code("*/ //");
							//js.Syntax.code('let [$ia, $ib] = {0}', $rhs);
							js.Syntax.code('let [{0}, {1}] = {2}', $a, $b, $rhs);
						};

					case macro [$a, $b]:
						final stmts = [];
						
						switch a {
							case macro @var ${ea = macro $i{ia}}:
								a = ea;
								stmts.push(macro var $ia: $cta);
								stmts.push(macro {
									js.Syntax.code("/*");
									$a = js.Syntax.code("*/ //");
								});
							default:
						}
						
						switch b {
							case macro @var ${eb = macro $i{ib}}:
								b = eb;
								stmts.push(macro var $ib: $ctb);
								stmts.push(macro {
									js.Syntax.code("/*");
									$b = js.Syntax.code("*/ //");
								});
							default:
						}
						
						stmts.push(
							macro js.Syntax.code("[{0}, {1}] = {2}", $a, $b, $rhs)
						);

						return macro @:mergeBlock $b{stmts};
					
					default:
						return Context.error("NYI!", lhs.pos);
				}
			
			default:
				return Context.error("NYI!", rhs.pos);
		}
	}

	@:noUsing
	static macro function deepIf(stmt) {
		var cond;
		function deepCopyF(expr: Expr) return switch expr {
			case macro @if ($_cond ? $then : $_else):
				cond = _cond;
				_else;
			case macro @if($_cond) $then:
				cond = _cond;
				macro {};
			case macro @unless($_cond) $then:
				cond = _cond;
				then;
			default: ExprTools.map(expr, deepCopyF);
		}
		function deepCopyT(expr: Expr) return switch expr {
			case macro @if ($_cond ? $then : $_else):
				then;
			case macro @if($_cond) $then:
				then;
			case macro @unless($_cond) $then:
				macro {};
			default: ExprTools.map(expr, deepCopyT);
		}

		final thenStmt = deepCopyT(stmt);
		final elseStmt = deepCopyF(stmt);

		return if(cond == null) thenStmt else macro if($cond) $thenStmt else $elseStmt;
	}
	
	/*=== FROM STAR UTIL (mostly) ===*/

	@:nullSafety(Strict)
	static macro function _and<T, U>(value: ExprOf<Null<T>>, and): ExprOf<Null<U>> {
		switch and { case macro $i{n} => $v:
			var dv = switch v {
				case {expr: EDisplay(v2, _)}: v2;
				default: v;
			};
			return macro switch($value) {
				case null: null;
				case Util._unsafeNonNull(_) => $i{n}: $dv;
			};
			
		default: throw "error!"; }
	}
	
	@:nullSafety(Strict)
	static macro function _or<T, U, V: T & U>(value: ExprOf<Null<T>>, or: ExprOf<U>): ExprOf<V> {
		return macro switch($value) {
			case null: $or;
			case Util._unsafeNonNull(_) => __anon__nonnull: __anon__nonnull;
		};
	}
	
	@:nullSafety(Strict)
	static macro function _andOr<T, U>(value: ExprOf<Null<T>>, and, or: ExprOf<U>): ExprOf<U> {
		switch and { case macro $i{n} => $v:
			var dv = switch v {
				case {expr: EDisplay(v2, _)}: v2;
				default: v;
			};
			return macro switch($value) {
				case null: $or;
				case Util._unsafeNonNull(_) => $i{n}: $dv;
			};
			
		default: throw "error!"; }
	}
	
	static inline function nonNull<T>(value: Null<T>): T {
		if(value != null)
			return value;
		else
			throw new NullException();
	}
	
	@:noCompletion @:noUsing
	static inline function _unsafeNonNull<T>(value: Null<T>) return (value : T);
	
	#if macro
	static function removeDisp(expr: Expr): Expr return switch expr {
		case {expr: EDisplay(expr2, k)}: removeDisp(expr2);
		default: ExprTools.map(expr, removeDisp);
	}

	@:noUsing
	public static function unify(ct1: ComplexType, ct2: ComplexType) {
		final t = Context.typeof(macro ([(null : $ct1), (null : $ct2)])[0]);
		final ct = Context.toComplexType(t).nonNull();
		return ct;
	}
	#end
	
	static macro function _match<T>(value: ExprOf<T>, cases: Array<Expr>): Expr {
		var defaultExpr = null;
		var caseExprs: Array<Case> = [];
		
		for(_case in cases) {
			switch _case {
				case macro at($pattern, when($cond)) => $expr: caseExprs.push({
					values: [pattern],
					guard: cond,
					expr: expr
				});

				case macro at($pattern) => $expr: caseExprs.push({
					values: [pattern],
					expr: expr
				});

				case macro _ => $expr: defaultExpr = expr;

				default: Context.error("error!", _case.pos);
			};
		}

		for(_case in caseExprs) {
			if(_case.values.length > 1) Context.error("wtf", _case.values[0].pos);
			
			var didChange = false;
			var anons = 0;
			var newVars: Array<{n: String, a: String, t: Null<{t: ComplexType, d: ComplexType}>}> = [];
			
			final pattern = _case.values[0];
			
			function collect(e: Expr): Expr return switch e {
				case {expr: EDisplay(expr2, k), pos: pos}:
					{expr: EDisplay(collect(expr2), k), pos: pos};
				
				case macro [$a{values}]: macro $a{values.map(collect)};
				
				case {expr: EIs(lhs, type), pos: pos}:
					final itype = switch type {
						case TPath({pack: p, name: n, params: _.length => l, sub: s}) if(l != 0):
							TPath({pack: p, name: n, sub: s});
						default: type;
					};
					final dtype = switch type {
						case TPath({pack: p, name: n, params: _.length => l, sub: s}) if(l != 0):
							TPath({pack: p, name: n, params: [for(_ in 0...l) TypeParam.TPType(macro:Dynamic)], sub: s});
						default: type;
					};
					
					switch lhs {
						case macro _:
							if(!didChange) didChange = true;
							macro $e => true;
						
						case macro $i{name}:
							if(!didChange) didChange = true;
							final anon = switch newVars.find(v -> v.n == name) {
								case null: '__anon${anons++}__$name';
								case v: v.a;
							};
							newVars.push({n: name, a: anon, t: {t: type, d: dtype}});
							macro ($i{anon} = ${{expr: EIs(macro _, itype), pos: pos}} => true);
						
						
						case macro ($l => $r):
							if(!didChange) didChange = true;
							macro (_ is $itype ? _ : null) => {a: _ != null, b: _} => {a: true, b: Util._unsafeNonNull(_) => ((untyped _ : $dtype) : $type) => $l => ${collect(r)}};
						
						default:
							if(!didChange) didChange = true;
							macro (_ is $itype ? ((untyped _ : $dtype) : $type) : null) => ${collect(lhs)};
					}
				
				case macro ${{expr: EIs(_, _)}} => ${_}: e;

				case (macro ${_} => true) | (macro ${_} => false): e;
				
				case {expr: EUnop(OpNot, true, lhs), pos: pos}:
					switch lhs {
						case macro _:
							if(!didChange) didChange = true;
							macro _ != null => true;
						
						case {expr: EUnop(OpNot, true, lhs2)}:
							if(!didChange) didChange = true;
							macro Util._unsafeNonNull(_) => $lhs2;
						
						case macro $i{name}:
							if(!didChange) didChange = true;
							final anon = '__anon${anons++}__$name';
							newVars.push({
								n: name,
								a: anon,
								t: null
							});
							if(_case.guard != null) {
								var found = false;
								function findVar(expr: Expr) {
									if(!found) switch expr {
										case macro $i{n} if(n == name): found = true;
										default: ExprTools.iter(expr, findVar);
									}
								}

								if({findVar(_case.guard); found;}) {
									_case.guard = macro {
										var $name = @:privateAccess Util._unsafeNonNull($i{anon});
										${_case.guard}
									};
								}
							}
							macro $i{anon} = _ != null => true;
						
						default: Context.error("NYI", pos);
					}
				
				case {expr: EBinop(OpInterval, begin, end)}:
					if(!didChange) didChange = true;
				
					final beginExcl = switch begin {
						case {expr: EUnop(OpNot, true, b)}:
							begin = b;
							true;
						default: false;
					};
					final endExcl = switch end {
						case {expr: EUnop(OpNot, false, e2)}:
							end = e2;
							true;
						default: false;
					};
					
					switch begin {
						case {expr: EField({expr: EConst(CIdent(_)) | EField({expr: EConst(CIdent(_))}, _)}, _) | EConst(CIdent(_)) | ECall(_)}: {
							final t = TypeTools.getEnum(switch begin {
								case macro $ec($a{_}): switch Context.typeExpr(ec).t {
									case TFun(_, t1): t1;
									default: Context.error("error!", begin.pos);
								}
								default: Context.typeExpr(begin).t;
							});
							
							function caseName(e: Expr) return switch e.expr {
								case ECall(e2, _): caseName(e2);
								case EField(_, n) | EConst(CIdent(n)): n;
								default: Context.error("error!", e.pos);
							}
							
							var start = t.names.indexOf(caseName(begin));
							var stop = t.names.indexOf(caseName(end));
							
							if(start == -1) Context.error("error!", begin.pos);
							if(stop == -1) Context.error("error!", end.pos);
							
							if(beginExcl) start++;
							if(endExcl) stop--;
							
							if(stop <= start) Context.error("error!", end.pos);
							
							function makeCase(i: Int) {
								return switch t.constructs[t.names[i]] {
									case {name: n, type: TFun(args, _)}: macro $i{n}($a{args.map(_ -> macro _)});
									case {name: n, type: _}: macro $i{n};
								}
							}
							
							var res = beginExcl ? makeCase(start) : begin;
							
							for(i in (start + 1)...(stop + 1)) {
								res = macro $res | ${makeCase(i)};
							}
							
							return res;
						}
						
						default: {
							var beginVal = switch begin {
								case {expr: EField({expr: EConst(CString(str, k))}, "code")}: nonNull(str.charCodeAt(0));
								default: ExprTools.getValue(begin);
							}
							var endVal = switch end {
								case {expr: EField({expr: EConst(CString(str, k))}, "code")}: nonNull(str.charCodeAt(0));
								default: ExprTools.getValue(end);
							};
							
							if(beginExcl) beginVal++;
							if(endExcl) endVal--;
							
							var res = macro $v{beginVal};
							
							while(beginVal < endVal) {
								res = macro $res | $v{++beginVal};
							}
							
							res;
						}
					}
				
				default: ExprTools.map(e, collect);
			}
			
			final newPattern = collect(pattern);
			
			if(didChange) {
				_case.values = [newPattern];
			}
			
			if(newVars.length != 0) {
				final vars = new Array<Var>();
				
				for(v in newVars) {
					switch vars.find(v2 -> v2.name == v.n) {
						case null: vars.push({
							name: v.n,
							expr: if(v.t == null) {
								macro Util._unsafeNonNull($i{v.a});
							} else {
								final vt = _unsafeNonNull(v.t).t;
								final vd = _unsafeNonNull(v.t).d;
								//macro (cast cast($i{v.a}, $vd) : $vt);
								macro (untyped (untyped $i{v.a} : $vd) : $vt);
							}
						});
						
						case (_ : Var) => v2:
							if(v.t == null) {
								Context.error("NYI", Context.currentPos());
							} else switch v2.expr {
								//case macro (cast cast($ve, $cd2) : $ct2):
								case macro (untyped (untyped $ve : $cd2) : $ct2):
									final ct1 = _unsafeNonNull(v.t).t;
									final t = Context.typeof(macro [(null : $ct1), (null : $ct2)][0]);
									final ct = Context.toComplexType(t).nonNull();
									final cd1 = _unsafeNonNull(v.t).d;
									final d = Context.typeof(macro [(null : $cd1), (null : $cd2)][0]);
									final cd = Context.toComplexType(t).nonNull();
									
									//v2.expr = macro (cast cast($ve, $ct) : $cd);
									v2.expr = macro (untyped (untyped $ve : $ct) : $cd);
									
								default: Context.error("error!", Context.currentPos());
							}
					}
				}
				
				_case.expr = macro {
					${{
						expr: EVars(vars),
						pos: Context.currentPos()
					}}
					${_case.expr}
				};
			}
		}

		return {
			expr: ESwitch(value, caseExprs, defaultExpr),
			pos: Context.currentPos()
		};
	}

#if macro
	private static function mapPattern(pattern: Expr, isOuter = false) return switch pattern {
		case {expr: EDisplay(e, _)}: macro ${mapPattern(e, isOuter)};
		case macro [$a{values}]: macro $a{values.map(v -> mapPattern(v))};
		case macro $l | $r: macro ${mapPattern(l)} | ${mapPattern(r)};
		default: pattern;
	}
#end
	
#if (!macro && js)
	@:noUsing
	static inline function tryCast<T: {}, S: T>(value: T, c: Class<S>): Option<S> {
		return if(@:privateAccess js.Boot.__downcastCheck(value, c)) Some(cast value) else None;
	}
#end
}