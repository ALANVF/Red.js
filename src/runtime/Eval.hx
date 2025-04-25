package runtime;

import types.Unset;
import types.JsRoutine;
import types.None;
import types.Logic;
import types.base.Context;
import types.Native;
import types.Action;
import types.Function;
import types.Op;
import types.JsRoutine;
import types.base.IFunction;
import types.Value;

@:publicFields
class Eval {
	static function evalCode(input: String) {
		return runtime.natives.Do.evalValues(Tokenizer.parse(input));
	}

	static function callAnyFunction(fn: IFunction, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		return fn._match(
			at(n is Native) => Natives.callNative(n, args, refines),
			at(a is Action) => Actions.callAction(a, args, refines),
			at(f is Function) => callFunction(f, args, refines),
			at(o is Op) => callAnyFunction(o.fn, args, refines),
			at(r is JsRoutine) => callJsRoutine(r, args, refines),
			_ => throw "error!"
		);
	}

	// TODO: allow refines to be null for perf reasons
	static function callFunction(fn: Function, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		final fctx = fn.ctx;
		final oldValues = fctx.values;
		fctx.values = fctx.values.copy();

		for(i => param in fn.params) {
			fctx.set(param.name, args[i]);
		}

		for(refine in fn.refines) {
			final name = refine.name.replace(Util.jsRx(~/-([a-z])/g), (_, l) -> l.toUpperCase());
			trace(refine,name, name);
			refines[name]._and(refArgs => {
				fctx.set(name, Logic.TRUE);
				for(j => param in refine.params) {
					fctx.set(param.name, refArgs[j]);
				}
			});
		}

		try {
			final res = runtime.natives.Do.evalValues(fn.body);
			fctx.values = oldValues;
			return res;
		} catch(e: RedError) {
			fctx.values = oldValues;
			if(e.error.isReturn()) {
				return e.error.get("arg1", false);
			} else {
				throw e;
			}
		};
	}

	static function callJsRoutine(r: JsRoutine, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		final refs: _Refs = {};

		for(ref in r.refines) {
			final name = ref.name.replace(Util.jsRx(~/-([a-z])/g), (_, l) -> l.toUpperCase());

			refines[ref.name]._andOr(refArgs => {
				Reflect.setField(refs, name, if(ref.params.length == 0) true else refArgs);
			}, {
				Reflect.setField(refs, name, if(ref.params.length == 0) false else null);
			});
		}

		final res = r.fn(args, refs);

		return js.Syntax.strictEq(res, js.Lib.undefined) ? cast Unset.UNSET
				: js.Syntax.strictEq(res, null) ? cast None.NONE
				: res;
	}
}