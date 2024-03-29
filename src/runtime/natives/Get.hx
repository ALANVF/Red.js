package runtime.natives;

import types.Block;
import types.Object;
import types.Unset;
import types.base.Options;
import types.base._NativeOptions;
import types.base._Path;
import types.base.IGetPath;
import types.base._AnyWord;
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
		} else if(value is IGetPath) {
			final access = {
				final v = path.pick(0).nonNull();
				v is Word ? v : Do.evalValue(v);
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
		} else if(value is IGetPath) {
			final value_ = cast(value, IGetPath);
			final access = path.pick(0)._and(v => v is Word ? v : Do.evalValue(v));
			return access
				._and(v => value_.getPath(v, ignoreCase))
				.flatMap(v -> _tryGetPath(v, path.skip(1), ignoreCase));
		} else {
			throw "error!";
		}
	}

	public static function getPath(path: _Path, ignoreCase = true) {
		return _getPath(Do.evalValue(path.pick(0).nonNull()), path.skip(1), ignoreCase);
	}

	public static function tryGetPath(path: _Path, ignoreCase = true) {
		return _tryGetPath(Do.evalValue(path.pick(0).nonNull()), path.skip(1), ignoreCase);
	}

	public static function call(word: Value, options: NGetOptions) {
		return word._match(
			at(s is _AnyWord) => {
				if(options.any && options._case) {
					if(s.context.contains(s.symbol.name, false)) {
						s.context.get(s.symbol.name, false);
					} else {
						Unset.UNSET;
					}
				} else if(!options.any && options._case) {
					switch s.context.get(s.symbol.name, false) {
						case Unset.UNSET: throw 'Word `${s.symbol.name}` doesn\'t exist!';
						case value: return value;
					}
				} else {
					s.get(options.any);
				}
			},
			at(p is _Path) => {
				if(options.any) {
					tryGetPath(p, options._case).orElse(Unset.UNSET);
				} else {
					getPath(p, options._case);
				}
			},
			at(o is Object) => new Block(o.ctx.values.copy()),
			_ => throw "Invalid type!"
		);
	}
}