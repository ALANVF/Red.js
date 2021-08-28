package runtime.natives;

import types.base._Block;
import types.Map;
import types.Object;
import types.Block;
import types.Unset;
import types.base.Symbol;
import types.base.Options;
import types.base._NativeOptions;
import types.base._Path;
import types.base.IGetPath;
import types.base.ISetPath;
import types.Value;
import types.Word;
import haxe.ds.Option;

using types.Helpers;

@:build(runtime.NativeBuilder.build())
class Set {
	public static final defaultOptions = Options.defaultFor(NSetOptions);

	static function _getPathUptoEnd(value: Value, path: _Path, ignoreCase: Bool) {
		inline function evalNext() {
			final v = path.pick(0).value();
			return v is Word ? v : Do.evalValue(v);
		}

		if(path.length == 1) {
			return {value: value, access: evalNext()};
		} else if(value is IGetPath) {
			final access = evalNext();
			final value_ = cast(value, IGetPath);
			return _getPathUptoEnd(value_.getPath(access, ignoreCase).value(), path.skip(1), ignoreCase);
		} else {
			throw "error!";
		}
	}

	public static function setPath(path: _Path, newValue: Value, ignoreCase = true) {
		_getPathUptoEnd(Do.evalValue(path.pick(0).value()), path.skip(1), ignoreCase)._match(
			at({value: value is ISetPath, access: access}) => {
				if(value.setPath(access, newValue, ignoreCase)) {
					return newValue;
				} else {
					throw "error!";
				}
			},
			_ => throw "error!"
		);
	}

	@:generic
	static function _setMany<Syms: Iterable<Symbol>, Vals: Iterable<Value>>(symbols: Syms, values: Vals, any, some) {
		final syms = symbols.iterator();
		final vals = values.iterator();

		switch [any, some] {
			case [true, true]:
				while(syms.hasNext() && vals.hasNext())
					switch vals.next() {
						case types.None.NONE:
						case val: syms.next().setValue(val);
					}
			
			case [false, true]:
				while(syms.hasNext() && vals.hasNext())
					switch vals.next() {
						case types.None.NONE:
						case Unset.UNSET: throw "Expected a value!";
						case val: syms.next().setValue(val);
					}
			
			case [true, false]:
				while(syms.hasNext() && vals.hasNext()) syms.next().setValue(vals.next());
				for(sym in syms) sym.setValue(types.None.NONE);
			
			case [false, false]:
				while(syms.hasNext() && vals.hasNext())
					switch vals.next() {
						case Unset.UNSET: throw "Expected a value!";
						case val: syms.next().setValue(val);
					}
				
				for(sym in syms) sym.setValue(types.None.NONE);
		}
	}

	@:generic
	public static function setMany<Iter: Iterable<Symbol>>(symbols: Iter, value: Value, any, only, some) {
		if(!(value == types.None.NONE && some)) {
			if(!only) {
				value._match(
					at(b is _Block) => _setMany(symbols, b, any, some),
					at(p is _Path) => _setMany(symbols, p, any, some),
					at(m is Map) => _setMany(symbols, m.keys.flatMap((k, i) -> [k, m.values[i]]), any, some),
					_ => for(s in symbols) s.setValue(value)
				);
			} else {
				for(s in symbols) s.setValue(value);
			}
		}
	}

	public static function call(word: Value, value: Value, options: NSetOptions) {
		if(value == Unset.UNSET && !options.any) {
			throw "Expected a value!";
		}

		word._match(
			at(s is Symbol) => s.setValue(value),
			at(p is _Path) => setPath(p, value, options._case),
			at(b is Block) => setMany([for(s in b) cast(s, Symbol)], value, options.any, options.only, options.some),
			at(o is Object) => setMany(o.ctx.symbols, value, options.any, options.only, options.some),
			_ => throw "Invalid type!"
		);

		return value;
	}
}