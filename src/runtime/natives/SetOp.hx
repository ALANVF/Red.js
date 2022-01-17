package runtime.natives;

import types.base.ComparisonOp;
import types.base._Block;
import types.base.Options;
import types.base._NativeOptions;
import types.base.IDatatype;
import types.*;
import js.Syntax.plainCode as emit;

final defaultOptions = Options.defaultFor(NSetOpOptions);

/*enum abstract SetOp(Int) {
	final OUnion;
	final OIntersect;
	final OExclude;
	final ODifference;
}*/

// TODO: correctly implement this according to https://github.com/red/red/blob/master/runtime/natives.reds#L1296

@:build(runtime.NativeBuilder.build())
class Union {
	static function forBlock(block1: _Block, block2: _Block, options: NSetOpOptions) {
		final step = options.skip._match(
			at({size: {int: size}}) => if(size <= 0) throw "invalid size" else size,
			_ => 1
		);

		final result = block1.copy();
		final cmp: ComparisonOp = options._case ? CStrictEqual : CEqual;
		
		var series2: Series<Value> = block2;
		
		while(series2.length >= step) {
			emit("check: { //"); {
				var i = 0;
				while(i+step <= result.absLength) {
					if(Actions.compare(result.values[i], series2[0], cmp) == Logic.TRUE) {
						emit("break check; /*");
						if(untyped null) break;
						emit("*/ //");
					}
					
					i += step;
				}

				if(step == 1) {
					result.values.push(series2[0]);
				} else {
					for(j in 0...step) {
						result.values.push(series2[j]);
					}
				}
			}; emit("} //");

			series2 += step;
		}

		return result;
	}

	static inline function forTypeset(ts1: Typeset, ts2: Typeset): Typeset {
		return new Typeset([ts1, ts2]);
	}

	// [block! hash! string! bitset! typeset!]
	public static function call(value1: Value, value2: Value, options: NSetOpOptions): Value {
		value1._match(
			at(b is Block | b is Hash) => value2._match(
				at(b2 is Block | b2 is Hash) => {
					return forBlock(b, b2, options);
				},
				_ => throw "invalid type"
			),
			at(str1 is String) => {
				throw "todo";
			},
			at(bs1 is Bitset) => {
				throw "todo";
			},
			at(ts1 is Typeset) => value2._match(
				at(ts2 is Typeset) => {
					return forTypeset(ts1, ts2);
				},
				_ => throw "invalid type"
			),
			_ => throw "invalid type"
		);
	}
}