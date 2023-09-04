package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._SeriesOf;
import types.base._BlockLike;
import types.base._String;
import types.base._Integer;
import types.Value;
import types.Integer;
import types.Char;
import types.Pair;
import types.Logic;
import types.None;
import types.Binary;

import runtime.actions.datatypes.ValueActions.invalid;

class SeriesActions<This: _SeriesOf<Elem, Val>, Elem: Value, Val> extends ValueActions<This> {
	/*-- Series actions --*/

	override function at(series: This, index: Value): This {
		final i = index._match(
			at(int is Integer) => int.int,
			at(pair is Pair) => pair.x,
			_ => throw "bad"
		);

		return cast series.at(i);
	}

	override function back(series: This): This {
		return cast series.skip(-1);
	}

	override function clear(series: This): This {
		series.values.splice(series.index, series.values.length - series.index);
		return series;
	}

	override function head(series: This): This {
		return cast series.head();
	}

	override function head_q(series: This): Logic {
		return Logic.fromCond(series.isHead());
	}

	override function index_q(series: This): Integer {
		return new Integer(series.index);
	}

	override function length_q(series: This): Integer {
		return new Integer(series.length);
	}

	override function next(series: This): This {
		return cast series.skip(1);
	}

	override function pick(series: This, index: Value): Value {
		return index._match(
			at({int: idx} is Integer) => {
				idx--;
				series._match(
					at(b is _BlockLike) => b.pick(idx) ?? cast None.NONE,
					// Vector
					at(b is Binary) => b.pick(idx) ?? cast None.NONE,
					at(s is _String) => s.pick(idx) ?? cast None.NONE,
					_ => invalid()
				);
			},
			_ => invalid()
		);
	}

	override function poke(series: This, index: Value, value: Value): Value {
		index._match(
			at({int: idx} is Integer) => {
				idx--;
				cast series._match(
					// Hash
					at(b is _BlockLike) => b.rawPoke(idx, value),
					at(b is Binary) => value._match(
						at(i is _Integer) => cast b.rawPoke(idx, i.int),
						_ => invalid()
					),
					// Vector
					at(s is _String) => value._match(
						at(c is Char) => cast s.rawPoke(idx, c.int),
						_ => invalid()
					),
					_ => invalid()
				) ?? throw "out of range";
			},
			_ => invalid()
		);
		return value;
	}

	override function skip(series: This, offset: Value): This {
		final i = offset._match(
			at(int is Integer) => int.int,
			at(pair is Pair) => pair.x,
			_ => throw "bad"
		);

		return cast series.skip(i);
	}

	override function tail(series: This): This {
		return cast series.tail();
	}

	override function tail_q(series: This): Logic {
		return Logic.fromCond(series.isTail());
	}
}