package runtime.natives;

import types.Block;
import types.Object;
import types.Unset;
import types.base.Options;
import types.base._NativeOptions;
import types.base._Path;
import types.base.IGetPath;
import types.base.Symbol;
import types.Value;
import types.Word;
import haxe.ds.Option;

using types.Helpers;

@:build(runtime.NativeBuilder.build())
class Get {
	public static final defaultOptions = Options.defaultFor(NGetOptions);

	static function _getPath(value: Value, path: _Path, ignoreCase: Bool) {
		if(path.length == 0) {
			return value;
		} else if((value is IGetPath)) {
			final access = {
				final v = path.pick(0).value();
				(v is Word) ? v : Do.evalValue(v);
			};
			final value_ = cast(value, IGetPath);
			return _getPath(value_.getPath(access, ignoreCase).value(), path.skip(1), ignoreCase);
		} else {
			throw "error!";
		}
	}

	static function _tryGetPath(value: Value, path: _Path, ignoreCase: Bool) {
		if(path.length == 0) {
			return Some(value);
		} else if((value is IGetPath)) {
			final value_ = cast(value, IGetPath);
			final access = path.pick(0).map(v -> (v is Word) ? v : Do.evalValue(v));
			return access
				.flatMap(v -> value_.getPath(v, ignoreCase))
				.flatMap(v -> _tryGetPath(v, path.skip(1), ignoreCase));
		} else {
			throw "error!";
		}
	}

	public static function getPath(path: _Path, ignoreCase = true) {
		return _getPath(Do.evalValue(path.pick(0).value()), path.skip(1), ignoreCase);
	}

	public static function tryGetPath(path: _Path, ignoreCase = true) {
		return _tryGetPath(Do.evalValue(path.pick(0).value()), path.skip(1), ignoreCase);
	}

	public static function call(word: Value, options: NGetOptions) {
		return switch word {
			case _.is(Symbol) => Some(s):
				if(options.any && options._case) {
					if(s.context.contains(s.name, false)) {
						s.context.get(s.name, false);
					} else {
						Unset.UNSET;
					}
				} else if(!options.any && options._case) {
					switch s.context.get(s.name, false) {
						case Unset.UNSET: throw 'Word `${s.name}` doesn\'t exist!';
						case value: return value;
					}
				} else {
					s.getValue(options.any);
				}

			case _.is(_Path) => Some(p):
				if(options.any) {
					tryGetPath(p, options._case).orElse(Unset.UNSET);
				} else {
					getPath(p, options._case);
				}
			
			case _.is(Object) => Some(o):
				new Block(o.ctx.values.copy());
			
			default:
				throw "Invalid type!";
		}
	}
}