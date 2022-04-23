package runtime;

import types.None;
import types.Logic;
import types.base.Context;
import types.Native;
import types.Action;
import types.Function;
import types.Op;
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
			_ => throw "error!"
		);
	}

	static function callFunction(fn: Function, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		final fctx = fn.ctx;
		final oldValues = fctx.values;
		fctx.values = fctx.values.copy();

		fn.params._for(i => param, {
			fctx.set(param.name, args[i]);
		});

		for(refine in fn.refines) {
			refines[refine.name]._match(
				at(refArgs!) => {
					fctx.set(refine.name, Logic.TRUE);
					for(j => param in refine.params) {
						fctx.set(param.name, refArgs[j]);
					}
				},
				_ => {}
			);
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
}