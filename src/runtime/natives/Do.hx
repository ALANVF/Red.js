package runtime.natives;

import runtime.actions.EvalPath;
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
import types.Function;
import types.base.Context;
import types.base.Options;
import types.base._NativeOptions;
import types.base._Path;
import types.base.IGetPath;
import types.base.IFunction;
import util.Tuple2;
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
			at(head is Word) => _doesBecomeFunction(head.get(), (path : Values).next()),
			_ => null
		);
	}

	static function checkForOp(values: Values) {
		return if(values.length >= 2) {
			values[0]._match(
				at((_.get(true) => o is Op) is Word) => o,
				at((doesBecomeFunction(_) => {_1: o is Op}) is Path) => o,
				_ => null
			);
		} else {
			null;
		}
	}

	static function groupParams(values: Values, params: Array<_Param>): Result<Array<GroupedExpr>> {
		return mkResult(
			{
				final res = Array.ofLength(params.length);
				for(i in 0...params.length) {
					detuple([res[i], values], groupNextExprForParam(values, params[i]));
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
				at(o!, when(o.params[0].quoting != QVal)) => {
					detuple(@var [left, values2], groupNextExprForParam(values, o.params[0]));
					return groupNextExprForParam(values2, o.params[0]).map(r -> GOp(left, o, r));
				},
				_ => {}
			);
		}

		return values++[0].nonNull()._match(
			at(s is SetWord) => groupNextExpr(values).map(e -> GSetWord(s, e)),
			at(s is SetPath) => groupNextExpr(values).map(e -> GSetPath(s, e)),
			at((_.get() => fn is IFunction) is Word) => // WE HAS DA FLOW TYPING!!!
				groupParams(values, fn.params).map(args -> GCall(fn, args, [])),
			at((doesBecomeFunction(_) => {_1: fn, _2: rest}) is Path) => {
				final args = groupParams(values, fn.params);

				if(rest.length == 0) {
					args.map(a -> GCall(fn, a, []));
				} else {
					final refines = new Dict();//: Dict<String, Array<GroupedExpr>> = [];

					values = args._2;

					for(value in rest) {
						value._match(
							at(w is Word) => switch fn.refines.find(ref -> w.symbol.equalsString(ref.name)) {
								case null: throw 'Unknown refinement `/${w.symbol.name}`!';
								case {name: n} if(refines.has(n)): throw 'Duplicate refinement `/${w.symbol.name}`!';
								case {name: n, params: params2}:
									detuple([@var refine, values], groupParams(values, params2));
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
				at(o!!) => groupNextExprForParam(++values, o.params[1]).map(e -> GOp(GValue(v), o, e))
			)
		);

		return new Result(GUnset, values);
	}

	public static function groupNextExprForParam(values: Values, param: _Param): Result<GroupedExpr> {
		return switch param.quoting {
			case QVal: groupNextExpr(values);
			case QGet if(values.isTail()): mkResult(GUnset, values);
			case QGet: mkResult(GNoEval(values++[0].nonNull()), values);
			case QLit:
				//eval-path pc pc + 1 end code no yes yes no
				mkResult(
					values++[0].nonNull()._match(
						at(v is Paren | v is GetWord | v is GetPath) => GValue(v),
						at(v) => GNoEval(v)
					),
					values
				);
		}
	}
	
	public static function evalPath(path: _Path, setValue: Null<Value>, isGet: Bool, /*isSub: Bool,*/ isCase: Bool) {
		var head = path.asSeries();
		if(head.isTail()) throw "empty path";

		var item = head + 1;
		var idx = 0;

		var pItem = head;
		var w = head.value._match(
			at(v is Word) => v,
			_ => throw "word first"
		);
		var parent = w.get(true);
		var gparent: Null<Value> = null;

		if(parent == Unset.UNSET) throw "unset path";

		if(w.context != Context.GLOBAL) {
			w.context.value._match(
				at(f is Function) => {
					gparent = f;
				},
				_ => {}
			);
		}

		var prevValue: Null<Value> = null;
		while(item.isNotTail()) {
			var value = item.value._match(
				at(w is GetWord) => w.get(),
				at(p is Paren) => evalValues(p),
				at(v) => v
			);
			if(value == Unset.UNSET) throw "invalid path";

			final prev = parent;
			final isTail = item.isEnd();
			final arg = isTail ? setValue : null;
			parent = EvalPath.call(parent, value, arg, path, gparent, pItem.value, idx, isCase, isGet, isTail);

			// hacky thingy for now bc idk how to get it to assign set-path scalars
			if(setValue != null && item.isEnd(1)) prevValue = value; 
			if(setValue != null && isTail && parent != arg) {
				if(prevValue == null) { // means path is just `foo/bar: baz`
					w.set(parent);
				} else {
					EvalPath.call(gparent, prevValue, parent, path, gparent, pItem[-1], idx-1, isCase, isGet, isTail);
				}
				parent = arg;
				break;
			}

			pItem.assign(item);
			gparent = prev;
			++item;
			++idx;
		}

		return parent;
	}

	public static function evalGroupedExpr(expr: GroupedExpr): Value {
		return switch expr {
			case GValue(value): evalValue(value);
			case GNoEval(value): value;
			case GSetWord(s, GUnset): throw '${s.symbol.name} needs a value!';
			case GSetWord(s, evalGroupedExpr(_) => value):
				if(value == Unset.UNSET) {
					throw '${s.symbol.name} needs a value!';
				} else {
					s.set(value);
					value;
				}
			case GSetPath(s, e): evalPath(s, evalGroupedExpr(e), false, false);
			case GOp(left, op, right):
				Eval.callAnyFunction(op, [evalGroupedExpr(left), evalGroupedExpr(right)], null);
			case GCall(fn, args, refines):
				Eval.callAnyFunction(
					fn,
					args.map(a -> evalGroupedExpr(a)),
					{
						final res = new Dict();
						for(k => v in refines) res[k] = v.map(a -> evalGroupedExpr(a));
						res;
					}
				);
			case GUnset: throw "Unexpected unset!";
		}
	}

	public static function evalValue(value: Value) {
		return value._match(
			at(p is Paren) => evalValues(p),
			at(p is Path) => evalPath(p, null, false, false),
			at(p is GetPath) => evalPath(p, null, true, false),
			at(l is LitPath) => new Path(l.values, l.index),
			at(w is Word) => w.get(),
			at(g is GetWord) => g.get(true),
			at(l is LitWord) => new Word(l.symbol),
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

	@:keep
	public static function call(value: Value, options: NDoOptions) {
		return options._match(
			at({expand: true} | {args: _!}) => throw 'NYI',
			at({next: {position: word}}) => value._match(
				at(b is Block | b is Paren) => {
					detuple(@var [v, rest], doNextValue(b));
					word.set(b.fastSkipHead(rest.offset));
					return v;
				},
				at(s is types.String) => {
					final values = Transcode.call(s, Transcode.defaultOptions);
					
					detuple(@var [v, rest], doNextValue(values));
					word.set(values.fastSkipHead(rest.offset));
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