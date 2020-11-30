package runtime.natives;

import types.base._Path;
import types.base.IGetPath;
import types.base.ISetPath;
import types.Value;
import types.Word;

using util.OptionTools;

class Set {
	static function _getPathUptoEnd(value: Value, path: _Path, ignoreCase: Bool) {
		inline function evalNext() {
			final v = path.pick(0).value();
			return (v is Word) ? v : Do.evalValue(v);
		}

		if(path.length == 1) {
			return {value: value, access: evalNext()};
		} else if((value is IGetPath)) {
			final access = evalNext();
			final value_ = cast(value, IGetPath);
			return _getPathUptoEnd(value_.getPath(access, ignoreCase).value(), path.skip(1), ignoreCase);
		} else {
			throw "error!";
		}
	}

	public static function setPath(path: _Path, newValue: Value, ignoreCase = true) {
		switch _getPathUptoEnd(Do.evalValue(path.pick(0).value()), path.skip(1), ignoreCase) {
			case {value: _value, access: access} if((_value is ISetPath)):
				final value = cast(_value, ISetPath);

				if(value.setPath(access, newValue, ignoreCase)) {
					return newValue;
				} else {
					throw "error!";
				}
			default:
				throw "error!";
		}
	}
}