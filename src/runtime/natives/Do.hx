package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.base._Path;
import types.Unset;
import types.Word;
import types.base.IGetPath;
import types.base.IFunction;
import haxe.ds.Option;
import types.Value;
import types.SetWord;
import types.SetPath;
import types.Op;
import types.Path;
import types.ValueKind;

using util.NullTools;
using util.ArrayTools;
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
	public static final defaultOptions = Options.defaultFor(NDoOptions);

	static function _doesBecomeFunction(value: Value, values: Iterator<Value>) {
		return switch value {
			case _.is(IFunction) => Some(fn): Some({fn: fn, rest: [for(v in values) v]});
			case _.is(IGetPath) => Some(g) if(values.hasNext()): g.getPath(values.next()).flatMap(_doesBecomeFunction.bind(_, values));
			default: None;
		}
	}

	static function doesBecomeFunction(path: Path) {
		return switch path.pick(0) {
			case Some(_.is(Word) => Some(head)): _doesBecomeFunction(head.getValue(), path.skip(1).iterator());
			default: None;
		}
	}

	static function checkForOp(tokens: Array<ValueKind>) {
		return if(tokens.length >= 2) {
			switch tokens[0] {
				case KWord(_.getValue(true).is(Op) => Some(o)): Some(o);
				case KPath(doesBecomeFunction(_) => Some({fn: _.is(Op) => Some(o)})): Some(o);
				default: None;
			}
		} else {
			None;
		}
	}

	static inline function groupArgs(tokens: Array<ValueKind>, args: Array<_Arg>) {
		return [for(arg in args) groupNextExprForArg(tokens, arg)];
	}

	public static function groupNextExpr(tokens: Array<ValueKind>) {
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

		return switch tokens.shift().notNull() {
			case KSetWord(s): GSetWord(s, groupNextExpr(tokens));
			case KSetPath(s): GSetPath(s, groupNextExpr(tokens));
			case KWord(_.getValue() => _fn) if((_fn is IFunction)):
				final fn = cast(_fn, IFunction); // I want flow-typing :'(
				GCall(fn, groupArgs(tokens, fn.args), []);
			case KPath(doesBecomeFunction(_) => Some({fn: fn, rest: rest})):
				final args = groupArgs(tokens, fn.args);

				if(rest.length == 0) {
					GCall(fn, args, []);
				} else {
					final refines = new Dict();//: Dict<String, Array<GroupedExpr>> = [];

					for(value in rest) {
						switch value.KIND {
							case KWord(w):
								switch fn.refines.find(ref -> w.equalsString(ref.name)) {
									case null:
										throw 'Unknown refinement `/${w.name}`!';
									case {name: n} if(refines.has(n)):
										throw 'Duplicate refinement `/${w.name}`!';
									case {name: n, args: args}:
										refines[n] = groupArgs(tokens, args);
								}
							default: throw "Invalid refinement!";
						}
					}

					GCall(fn, args, refines);
				}
			case _.getValue() => v:
				switch checkForOp(tokens) {
					case Some(o):
						tokens.shift();
						GOp(GValue(v), o, groupNextExprForArg(tokens, o.args[1]));
					case None:
						GValue(v);
				}
		}
	}

	public static function groupNextExprForArg(tokens: Array<ValueKind>, arg: _Arg) {
		return switch arg.quoting {
			case QVal: groupNextExpr(tokens);
			case QGet if(tokens.length == 0): GUnset;
			case QGet: GNoEval(tokens.shift().notNull().getValue());
			case QLit:
				final k = tokens.shift().notNull();
				final v = k.getValue();
				if(k.match(KParen(_) | KGetWord(_) | KGetPath(_))) { // That's a bruh moment
					GValue(v);
				} else {
					GNoEval(v);
				}
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
		return switch value.KIND {
			case KParen(p): evalValues(p);
			case KPath((_ : _Path) => p) | KGetPath(p): Get.getPath(p);
			case KLitPath(l): new Path(l.values, l.index);
			case KWord(w): w.getValue();
			case KGetWord(g): g.getValue(true);
			case KLitWord(l): new Word(l.name, l.context, l.offset);
			default: value;
		}
	}

	public static function evalValues(values: Iterable<Value>) {
		final tokens = [for(v in values) v.KIND];
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
			final values_ = [for(v in values) v.KIND];
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
			case {next: Some({position: word})}: switch value.KIND {
				case KBlock((_ : types.base._Block) => b) | KParen(b):
					switch doNextValue(b) {
						case {value: v, offset: o}:
							word.setValue(b.skip(o));
							return v;
					}
				case KString(s):
					final values = Transcode.call(s, Transcode.defaultOptions);
					
					switch doNextValue(values) {
						case {value: v, offset: o}:
							word.setValue(values.skip(o));
							return v;
					}
				case KFile(_) | KUrl(_): throw 'NYI';
				default: evalValue(value);
			}
			default: switch value.KIND {
				case KBlock((_ : types.base._Block) => body) | KParen(body): evalValues(body);
				case KString(s): evalValues(Transcode.call(s, Transcode.defaultOptions));
				case KFile(_) | KUrl(_): throw 'NYI';
				default: evalValue(value);
			}
		}
	}
}