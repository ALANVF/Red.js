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

	override function copy(series: This, options: ACopyOptions): This {
		final s = series.values;
		var offset = series.index;
		final len = series.absLength;
		var part = (len - offset).max(0);

		if(options.types != null) throw "NYI";
		
		options.part?.length._and(p => {
			part = p._match(
				at(i is Integer) => i.int,
				at({x: x, y: y} is Pair) => {
					offset += x - 1;
					if(x < 0) offset++;
					if(offset < 0) offset = 0;
					if(y < x) 0 else y - x;
				},
				at(s is _SeriesOf<Elem, Val>) => {
					if(series.values != s.values) invalid();
					s.index - series.index;
				},
				_ => invalid()
			);
			if(part < 0) {
				part *= -1;
				offset -= part;
				if(offset < 0) {
					offset = 0;
					part = series.index;
				}
			}
		});

		if(offset > len) {
			part = 0;
			offset = len;
		}
		if(offset + part > len) {
			part = len - offset;
		}
		
		return cast @:privateAccess series.clone(s.slice(offset, offset + part));
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

	override function swap(series1: This, series2: Value): This {
		if(series1.length == 0) return series1;
		series2._match(
			at(s2 is _String) => {
				if(s2.length == 0) return series1;
				final s1 = (cast series1 : _String);
				final char1 = s1.rawFastPick(0);
				final char2 = s2.rawFastPick(0);
				s1.rawFastPoke(0, char2);
				s2.rawFastPoke(0, char1);
				return series1;
			},
			_ => throw "bad"
		);
	}

	override function tail(series: This): This {
		return cast series.tail();
	}

	override function tail_q(series: This): Logic {
		return Logic.fromCond(series.isTail());
	}

	override function take(series: This, options: ATakeOptions): Value {
		var size = series.length;
		if(size <= 0) return None.NONE;

		var part = 1;
		var part2 = 1;
		var ser2 = null;
		final hasPart = options.part?.length._andOr(p => {
			part = p._match(
				at(i is Integer) => i.int,
				at(s is _SeriesOf<Elem, Val>) => {
					if(!series.sameSeriesAs(s)) throw "bad";
					ser2 = s;
					if(ser2.index < series.index) 0;
					else if(options.last) size - (ser2.index - series.index);
					else ser2.index - series.index;
				},
				_ => invalid()
			);
			part2 = part;
			if(part < 0) {
				size = series.index;
				part = if(options.last) 1 else -part;
			}
			true;
		}, {
			false;
		});

		if(!hasPart) {
			return if(options.last) {
				cast @:privateAccess series.wrap(series.values.pop());
			} else if(series.index == 0) {
				cast @:privateAccess series.wrap(series.values.shift());
			} else {
				cast @:privateAccess series.wrap(series.values.splice(series.index, 1)[0]);
			}
		}

		var offset = series.index;
		
		if(part2 > 0) {
			if(options.last) {
				offset = series.length - part;
			}
		} else {
			if(options.last || part > series.absLength) return @:privateAccess series.clone([]);
			offset -= part;
		}

		return @:privateAccess series.clone(series.values.splice(offset, part));
	}
}