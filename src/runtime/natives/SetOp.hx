package runtime.natives;

import types.base.MathOp;
import types.base.ComparisonOp;
import types.base._Block;
import types.base.Options;
import types.base._NativeOptions;
import types.base.IDatatype;
import types.*;
import runtime.actions.datatypes.BlockActions;
import runtime.actions.datatypes.StringActions;
import runtime.actions.datatypes.BitsetActions;
import runtime.actions.datatypes.TypesetActions;
import runtime.actions.datatypes.DateActions;

import js.Syntax.plainCode as emit;

final defaultOptions = Options.defaultFor(NSetOpOptions);

function doSetOp(value1: Value, value2: Value, op: MathOp, options: NSetOpOptions) {
	final step = options.skip._match(
		at({size: {int: size}}) => if(size <= 0) throw "invalid size" else size,
		_ => 1
	);
	final isCase = options._case;

	if(op != OUnique && value1.thisType() != value2.thisType()) {
		throw "invalid type";
	}

	return value1._match(
		at(b is Block | b is Hash) => throw "todo", // BlockActions.doSetOp(b, value2, op, isCase, skip),
		at(s is String) => throw "todo", // StringActions.doSetOp(s, value2, op, isCase, skip),
		at(b is Bitset) => throw "todo", // BitsetActions.doBitwise(b, value2, op),
		at(t is Typeset) => TypesetActions.doBitwise(t, value2, op),
		at(d is Date) => {
			if(op != ODifference) throw "invalid type";
			throw "todo"; // DateActions.difference(d, Std.downcast(value2, Date) ?? throw "invalid type");
		},
		_ => throw "invalid type"
	);
}

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

	public static function call(value1: Value, value2: Value, options: NSetOpOptions): Value {
		return doSetOp(value1, value2, OUnion, options);
	}
}

@:build(runtime.NativeBuilder.build())
class Intersect {
	public static function call(value1: Value, value2: Value, options: NSetOpOptions): Value {
		return doSetOp(value1, value2, OIntersect, options);
	}
}

@:build(runtime.NativeBuilder.build())
class Unique {
	public static function call(value: Value, options: NSetOpOptions): Value {
		return doSetOp(value, value, OUnique, options);
	}
}

@:build(runtime.NativeBuilder.build())
class Difference {
	public static function call(value1: Value, value2: Value, options: NSetOpOptions): Value {
		return doSetOp(value1, value2, ODifference, options);
	}
}

@:build(runtime.NativeBuilder.build())
class Exclude {
	public static function call(value1: Value, value2: Value, options: NSetOpOptions): Value {
		return doSetOp(value1, value2, OExclude, options);
	}
}