package runtime.natives;

import types.*;
import types.base._Number;

function minmax(value1: Value, value2: Value, isMax: Bool): Value {
	value1._match(
		at({x: x1, y: y1} is Pair) => {
			final res = new Pair(x1, y1);
			
			value2._match(
				at({x: x2, y: y2} is Pair) => {
					if(isMax) {
						if(x1 < x2) res.x = x2;
						if(y1 < y2) res.y = y2;
					} else {
						if(x1 > x2) res.x = x2;
						if(y1 > y2) res.y = y2;
					}
					return res;
				},
				at(num is _Number) => {
					final i = num.asInt();
					if(isMax) {
						if(x1 < i) res.x = i;
						if(y1 < i) res.y = i;
					} else {
						if(x1 > i) res.x = i;
						if(y1 > i) res.y = i;
					}
					return res;
				},
				_ => {}
			);
		},
		at({values: values1} is Tuple) => {
			final res = values1.slice();
			
			value2._match(
				at({values: values2} is Tuple, when(res.length == values2.length)) => {
					Util.deepIf(
						for(i in 0...res.length) {
							final v1 = res[i];
							final v2 = values2[i];
							if(@if (isMax ? v1 < v2 : v1 > v2)) {
								res[i] = v2;
							}
						}
					);
					return new Tuple(res);
				},
				at(num is _Number) => {
					final n = num.asInt();
					final b = Math.clamp(0, n, 255);
					Util.deepIf(
						for(i in 0...res.length) {
							final v = res[i];
							if(@if (isMax ? v < b : v > b)) {
								res[i] = b;
							}
						}
					);
					return new Tuple(res);
				},
				_ => {}
			);
		},
		_ => {}
	);

	if(Actions.compare(value1, value2, CLesser).cond == isMax) {
		return value2;
	} else {
		return value1;
	}
}

@:build(runtime.NativeBuilder.build())
class Min {
	public static function call(value1: Value, value2: Value) {
		return minmax(value1, value2, false);
	}
}

@:build(runtime.NativeBuilder.build())
class Max {
	public static function call(value1: Value, value2: Value) {
		return minmax(value1, value2, true);
	}
}