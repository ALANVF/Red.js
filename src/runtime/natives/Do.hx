package runtime.natives;

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

//using util.NullTools;
using types.Helpers;

// THING: https://github.com/meijeru/red.specs-public/blob/master/specs.adoc#423-atomiccomposite-types

enum GroupedExpr {
	GValue(v: Value);
	GNoEval(v: Value);
	GSetWord(s: SetWord, e: GroupedExpr);
	GSetPath(s: SetPath, e: GroupedExpr);
	GOp(l: GroupedExpr, op: Op, r: GroupedExpr);
	GCall(f: IFunction, args: Array<GroupedExpr>, refines: Dict<String, Array<GroupedExpr>>);
	GUnset;
}

@:build(runtime.NativeBuilder.build())
class Do {
	// Hack to fix "maybe loop in static generation of runtime.natives.Do" bug
	static function __init__() {
		runtime.actions.datatypes.NativeActions.MAPPINGS["NAT_DO"] = types.Native.NativeFn.NDo(js.Syntax.code("{0}.call", Do));
	}

	public static final defaultOptions = Options.defaultFor(NDoOptions);

	static function _doesBecomeFunction(value: Value, values: Iterator<Value>):Option<{fn: IFunction, rest: Array<Value>}> {
		return value._match(
			at(fn is IFunction) => Some({fn: fn, rest: [for(v in values) v]}),
			at(g is IGetPath, when(values.hasNext())) => g.getPath(values.next()).flatMap(v -> _doesBecomeFunction(v, values)),
			_ => None
		);
	}

	static function doesBecomeFunction(path: Path) {
		return path.pick(0)._match(
			at(Some(head is Word)) => _doesBecomeFunction(head.getValue(), path.skip(1).iterator()),
			_ => None
		);
	}
	
	static function checkForOp(tokens: Array<Value>) {
		return if(tokens.length >= 2) {
			tokens[0]._match(
				at((_.getValue(true) => o is Op) is Word) => Some(o),
				at((doesBecomeFunction(_) => Some({fn: o is Op})) is Path) => Some(o),
				_ => None
			);
		} else {
			None;
		}
	}

	static inline function groupArgs(tokens: Array<Value>, args: Array<_Arg>) {
		return [for(arg in args) groupNextExprForArg(tokens, arg)];
	}

	public static function groupNextExpr(tokens: Array<Value>) {
		// look-ahead in case there's an op! after the value with a lit-word! or get-word! LHS
		if(tokens.length >= 3) {
			switch checkForOp(tokens.slice(1)) {
				case Some(o) if(o.args[0].quoting != QVal):
					final left = groupNextExprForArg(tokens, o.args[0]);
					tokens.shift();
					return GOp(left, o, groupNextExprForArg(tokens, o.args[0]));
				default:
			}
		}

		return tokens.shift().nonNull()._match(
			at(s is SetWord) => GSetWord(s, groupNextExpr(tokens)),
			at(s is SetPath) => GSetPath(s, groupNextExpr(tokens)),
			at((_.getValue() => fn is IFunction) is Word) => // WE HAS DA FLOW TYPING!!!
				GCall(fn, groupArgs(tokens, fn.args), []),
			at((doesBecomeFunction(_) => Some({fn: fn, rest: rest})) is Path) => {
				final args = groupArgs(tokens, fn.args);

				if(rest.length == 0) {
					GCall(fn, args, []);
				} else {
					final refines = new Dict();//: Dict<String, Array<GroupedExpr>> = [];

					for(value in rest) {
						value._match(
							at(w is Word) => switch fn.refines.find(ref -> w.equalsString(ref.name)) {
								case null: throw 'Unknown refinement `/${w.name}`!';
								case {name: n} if(refines.has(n)): throw 'Duplicate refinement `/${w.name}`!';
								case {name: n, args: args}: refines[n] = groupArgs(tokens, args);
							},
							_ => throw "Invalid refinement!"
						);
					}

					GCall(fn, args, refines);
				}
			},
			at(v) => switch checkForOp(tokens) {
				case Some(o):
					tokens.shift();
					GOp(GValue(v), o, groupNextExprForArg(tokens, o.args[1]));
				case None:
					GValue(v);
			}
		);
	}

	public static function groupNextExprForArg(tokens: Array<Value>, arg: _Arg) {
		return switch arg.quoting {
			case QVal: groupNextExpr(tokens);
			case QGet if(tokens.length == 0): GUnset;
			case QGet: GNoEval(tokens.shift().nonNull());
			case QLit:
				tokens.shift().nonNull()._match(
					at(v is Paren | v is GetWord | v is GetPath) => GValue(v),
					at(v) => GNoEval(v)
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
					args.map(evalGroupedExpr),
					[for(k => v in refines) k => v.map(evalGroupedExpr)]
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

	public static function evalValues(values: Iterable<Value>) {
		final tokens = [for(v in values) v];
		var result: Value = Unset.UNSET;
		
		while(tokens.length != 0) {
			result = evalGroupedExpr(groupNextExpr(tokens));
		}

		return result;
	}

	public static function doNextValue(values: Iterable<Value> & {var length(get, never): Int;}) {
		if(values.length == 0) {
			return {
				value: (Unset.UNSET : Value),
				offset: 0
			};
		} else {
			final values_ = [for(v in values) v];
			final value = groupNextExpr(values_);
			
			return {
				value: evalGroupedExpr(value),
				offset: values.length - values_.length
			};
		}
	}
	
	public static function call(value: Value, options: NDoOptions) {
		return switch options {
			case {expand: true} | {args: Some(_)}: throw 'NYI';
			case {next: Some({position: word})}: value._match(
				at(b is Block | b is Paren) =>
					switch doNextValue(b) {
						case {value: v, offset: o}:
							word.setValue(b.skip(o));
							return v;
					},
				at(s is types.String) => {
					final values = Transcode.call(s, Transcode.defaultOptions);
					
					switch doNextValue(values) {
						case {value: v, offset: o}:
							word.setValue(values.skip(o));
							return v;
					}
				},
				at(_ is File | _ is Url) => throw 'NYI',
				_ => evalValue(value)
			);
			default: value._match(
				at(body is Block | body is Paren) => evalValues(body),
				at(s is types.String) => evalValues(Transcode.call(s, Transcode.defaultOptions)),
				at(_ is File | _ is Url) => throw 'NYI',
				_ => evalValue(value)
			);
		}
	}
}