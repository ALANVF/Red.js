package runtime.natives;

import types.base._Path;
import types.base.IGetPath;
import types.Value;
import types.Word;
import haxe.ds.Option;

using util.OptionTools;

class Get {
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
}