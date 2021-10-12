package runtime.natives;

import types.Tuple;
import util.Tuple2;
import types.Value;
import types.Op;
import types.Path;
import types.GetPath;
import types.SetPath;
import types.LitPath;
import types.Word;
import types.GetWord;
import types.SetWord;
import types.LitWord;
import types.Block;
import types.Paren;
import types.Unset;
import types.File;
import types.Url;
import types.base.Options;
import types.base._NativeOptions;
import types.base._Path;
import types.base.IGetPath;
import types.base.IFunction;
import haxe.ds.Option;
import Util.detuple;

using types.Helpers;

// THING: https://github.com/meijeru/red.specs-public/blob/master/specs.adoc#423-atomiccomposite-types

private typedef Values = Series<Value>;

enum GroupedExpr {
	GValue(v: Value);
	GNoEval(v: Value);
	GSetWord(s: SetWord, e: GroupedExpr);
	GSetPath(s: SetPath, e: GroupedExpr);
	GOp(l: GroupedExpr, op: Op, r: GroupedExpr);
	GCall(f: IFunction, args: Array<GroupedExpr>, refines: Dict<String, Array<GroupedExpr>>);
	GUnset;
}

@:using(runtime.natives.Do.ResultTools)
typedef Result<T> = Tuple2<T, Values>;

@:publicFields
class ResultTools {
	static inline function map<T, U>(self: Result<T>, func: (T) -> U): Result<U> {
		return new Result<U>(func(self._1), self._2);
	}
}

inline function mkResult<T>(value: T, values: Values): Result<T> {
	return new Result(value, values);
}

@:build(runtime.NativeBuilder.build())
class Do {
	// Hack to fix "maybe loop in static generation of runtime.natives.Do" bug
	static function __init__() {
		runtime.actions.datatypes.NativeActions.MAPPINGS["NAT_DO"] = types.Native.NativeFn.NDo(js.Syntax.code("{0}.call", Do));
	}

	public static final defaultOptions = Options.defaultFor(NDoOptions);
	
	static function _doesBecomeFunction(value: Value, values: Values) {
		return value._match(
			at(fn is IFunction) => mkResult(fn, values),
			at(g is IGetPath, when(values.isNotTail())) => switch g.getPath(values++[0]) {
				case Some(v): _doesBecomeFunction(v, values);
				case None: null;
			},
			_ => null
		);
	}

	static function doesBecomeFunction(path: Path) {
		return path.pick(0)._match(
			at(Some(head is Word)) => _doesBecomeFunction(head.getValue(), (path : Values).next()),
			_ => null
		);
	}

	static function checkForOp(values: Values) {
		return if(values.length >= 2) {
			values[0]._match(
				at((_.getValue(true) => o is Op) is Word) => o,
				at((doesBecomeFunction(_) => {_1: o is Op}) is Path) => o,
				_ => null
			);
		} else {
			null;
		}
	}

	static function groupArgs(values: Values, args: Array<_Arg>): Result<Array<GroupedExpr>> {
		return mkResult(
			{
				final res = Array.ofLength(args.length);
				for(i in 0...args.length) {
					detuple([res[i], values], groupNextExprForArg(values, args[i]));
				}
				res;
			},
			values
		);
	}

	public static function groupNextExpr(values: Values) {
		// look-ahead in case there's an op! after the value with a lit-word! or get-word! LHS
		if(values.length >= 3) {
			checkForOp(values.next())._match(
				at(o!, when(o.args[0].quoting != QVal)) => {
					detuple(@var [left, values2], groupNextExprForArg(values, o.args[0]));
					return groupNextExprForArg(values2, o.args[0]).map(r -> GOp(left, o, r));
				},
				_ => {}
			);
		}

		return values++[0].nonNull()._match(
			at(s is SetWord) => groupNextExpr(values).map(e -> GSetWord(s, e)),
			at(s is SetPath) => groupNextExpr(values).map(e -> GSetPath(s, e)),
			at((_.getValue() => fn is IFunction) is Word) => // WE HAS DA FLOW TYPING!!!
				groupArgs(values, fn.args).map(args -> GCall(fn, args, [])),
			at((doesBecomeFunction(_) => {_1: fn, _2: rest}) is Path) => {
				final args = groupArgs(values, fn.args);

				if(rest.length == 0) {
					args.map(a -> GCall(fn, a, []));
				} else {
					final refines = new Dict();//: Dict<String, Array<GroupedExpr>> = [];

					values = args._2;

					for(value in rest) {
						value._match(
							at(w is Word) => switch fn.refines.find(ref -> w.equalsString(ref.name)) {
								case null: throw 'Unknown refinement `/${w.name}`!';
								case {name: n} if(refines.has(n)): throw 'Duplicate refinement `/${w.name}`!';
								case {name: n, args: args2}:
									detuple([@var refine, values], groupArgs(values, args2));
									refines[n] = refine;
							},
							_ => throw "Invalid refinement!"
						);
					}
					
					new Result(GCall(fn, args._1, refines), values);
				}
			},
			at(v) => checkForOp(values)._match(
				at(null) => mkResult(GValue(v), values),
				at(o!!) => groupNextExprForArg(++values, o.args[1]).map(e -> GOp(GValue(v), o, e))
			)
		);

		return new Result(GUnset, values);
	}

	public static function groupNextExprForArg(values: Values, arg: _Arg): Result<GroupedExpr> {
		return switch arg.quoting {
			case QVal: groupNextExpr(values);
			case QGet if(values.isTail()): mkResult(GUnset, values);
			case QGet: mkResult(GNoEval(values++[0].nonNull()), values);
			case QLit:
				mkResult(
					values++[0].nonNull()._match(
						at(v is Paren | v is GetWord | v is GetPath) => GValue(v),
						at(v) => GNoEval(v)
					),
					values
				);
		}
	}

	public static function evalGroupedExpr(expr: GroupedExpr): Value {
		return switch expr {
			case GValue(value): evalValue(value);
			case GNoEval(value): value;
			case GSetWord(s, GUnset): throw '${s.name} needs a value!';
			case GSetWord(s, evalGroupedExpr(_) => value):
				if(value == Unset.UNSET) {
					throw '${s.name} needs a value!';
				} else {
					s.setValue(value);
				}
			case GSetPath(s, e): Set.setPath(s, evalGroupedExpr(e));
			case GOp(left, op, right): throw "NYI";
			case GCall(fn, args, refines):
				Eval.callFunction(
					fn,
					args.map(a -> evalGroupedExpr(a)),
					[for(k => v in refines) k => v.map(a -> evalGroupedExpr(a))] // TODO: fix bad codegen
				);
			case GUnset: throw "Unexpected unset!";
		}
	}

	public static function evalValue(value: Value) {
		return value._match(
			at(p is Paren) => evalValues(p),
			at(p is Path | p is GetPath) => Get.getPath(p),
			at(l is LitPath) => new Path(l.values, l.index),
			at(w is Word) => w.getValue(),
			at(g is GetWord) => g.getValue(true),
			at(l is LitWord) => new Word(l.name, l.context, l.offset),
			_ => value
		);
	}

	public static function evalValues(values: Values) {
		var result: Value = Unset.UNSET;
		
		while(values.isNotTail()) {
			detuple([@var expr, values], groupNextExpr(values));
			result = evalGroupedExpr(expr);
		}

		return result;
	}

	public static function doNextValue(values: Values): Result<Value> {
		if(values.length == 0) {
			return mkResult(cast Unset.UNSET, values);
		} else {
			return groupNextExpr(values).map(value -> evalGroupedExpr(value));
		}
	}

	public static function call(value: Value, options: NDoOptions) {
		return options._match(
			at({expand: true} | {args: _!}) => throw 'NYI',
			at({next: {position: word}}) => value._match(
				at(b is Block | b is Paren) => {
					detuple(@var [v, rest], doNextValue(b));
					word.setValue(b.fastSkipHead(rest.offset));
					return v;
				},
				at(s is types.String) => {
					final values = Transcode.call(s, Transcode.defaultOptions);
					
					detuple(@var [v, rest], doNextValue(values));
					word.setValue(values.fastSkipHead(rest.offset));
					return v;
				},
				at(_ is File | _ is Url) => throw 'NYI',
				_ => evalValue(value)
			),
			_ => value._match(
				at(body is Block | body is Paren) => evalValues(body),
				at(s is types.String) => evalValues(Transcode.call(s, Transcode.defaultOptions)),
				at(_ is File | _ is Url) => throw 'NYI',
				_ => evalValue(value)
			)
		);
	}
}