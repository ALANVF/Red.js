package runtime.natives;

import types.Logic;
import types.Value;

@:build(runtime.NativeBuilder.build())
class Equal_q {
	public static inline function call(value1: Value, value2: Value) {
		return Actions.compare(value1, value2, CEqual);
	}
}

@:build(runtime.NativeBuilder.build())
class NotEqual_q {
	public static inline function call(value1: Value, value2: Value) {
		return Actions.compare(value1, value2, CNotEqual);
	}
}

@:build(runtime.NativeBuilder.build())
class StrictEqual_q {
	public static inline function call(value1: Value, value2: Value) {
		return Actions.compare(value1, value2, CStrictEqual);
	}
}

@:build(runtime.NativeBuilder.build())
class Lesser_q {
	public static inline function call(value1: Value, value2: Value) {
		return Actions.compare(value1, value2, CLesser);
	}
}

@:build(runtime.NativeBuilder.build())
class LesserOrEqual_q {
	public static inline function call(value1: Value, value2: Value) {
		return Actions.compare(value1, value2, CLesserEqual);
	}
}

@:build(runtime.NativeBuilder.build())
class Greater_q {
	public static inline function call(value1: Value, value2: Value) {
		return Actions.compare(value1, value2, CGreater);
	}
}

@:build(runtime.NativeBuilder.build())
class GreaterOrEqual_q {
	public static inline function call(value1: Value, value2: Value) {
		return Actions.compare(value1, value2, CGreaterEqual);
	}
}

@:build(runtime.NativeBuilder.build())
class Same_q {
	public static inline function call(value1: Value, value2: Value) {
		return if(value1.TYPE_KIND != value2.TYPE_KIND) {
			Logic.FALSE;
		} else {
			Actions.compare(value1, value2, CSame);
		}
	}
}