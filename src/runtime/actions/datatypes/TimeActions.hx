package runtime.actions.datatypes;

import types.base._ActionOptions;
import types.base.ComparisonOp;
import types.base.CompareResult;
import types.base._Integer;
import types.base._Float;
import types.base._Block;
import types.base._Path;
import types.Value;
import types.Integer;
import types.Float;
import types.Money;
import types.Time;
import types.Percent;
import types.Logic;
import types.Word;

import runtime.actions.datatypes.ValueActions.invalid;

class TimeActions extends FloatActions<Time> {
	private static inline final H_FACTOR = 3600.0;
	private static inline final M_FACTOR = 60.0;

	override function makeThis(f: StdTypes.Float): Time {
		return new Time(f);
	}

	function getHours(time: StdTypes.Float) {
		time /= H_FACTOR;
		return Math.trunc(time);
	}

	function getMinutes(time: StdTypes.Float) {
		if(time < 0) time = -time;
		return Math.floor((time % H_FACTOR) / M_FACTOR);
	}

	inline function getSeconds(time: StdTypes.Float) {
		return time % M_FACTOR;
	}

	function getNamedIndex(w: Word, ref: Value) {
		final sym = w.symbol;
		var idx = -1;
		if(sym == Words.HOUR) idx = 1;
		else if(sym == Words.MINUTE) idx = 2;
		else if(sym == Words.SECOND) idx = 3;
		else if(ref is Time) throw "cannot use";
		return idx;
	}

	function getField(time: StdTypes.Float, field: Int) {
		return field._match(
			at(1) => new Integer(getHours(time)),
			at(2) => new Integer(getMinutes(time)),
			at(3) => new Float(getSeconds(time)),
			_ => throw "bad"
		);
	}


	override function to(_, spec: Value) {
		return spec._match(
			at(t is Time) => t,
			at(i is Integer) => new Time(i.int),
			at(f is _Float) => new Time(f.float),
			at(b is _Block) => {
				final len = b.length;
				if(len > 3) invalid();
				var f1 = 0.0;
				var t = 0.0;
				var isNeg = false;
				for(i in 0...len) {
					final v = b.fastPick(i);
					var f = v._match(
						at(v is Float, when(i == 2)) => {
							f1 = v.float;
							f1;
						},
						at(v is Integer) => v.int,
						_ => invalid()
					);
					if(f < 0) {
						if(i == 0) {
							f = -f;
							isNeg = true;
						} else {
							invalid();
						}
					}
					t = i._match(
						at(0) => t + f * H_FACTOR,
						at(1) => t + f * M_FACTOR,
						_ => t + f
					);
				}
				if(isNeg) t = -t;
				new Time(t);
			},
			// _String
			_ => invalid()
		);
	}

	override function evalPath(
		parent: Time, element: Value, value: Null<Value>,
		path: Null<_Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	): Value {
		final time = parent.float;

		final field = element._match(
			at(i is Integer) => i.int,
			at(w is Word) => getNamedIndex(w, path),
			_ => -1
		);
		if(field <= 0 || field > 3) invalid();

		value._andOr(value => {
			return new Time(field._match(
				at(1) => value._match(
					at(i is Integer) => time - ((getHours(time) - i.int) * H_FACTOR),
					_ => invalid()
				),
				at(2) => value._match(
					at(i is Integer) => time - ((getMinutes(time) - i.int) * M_FACTOR),
					_ => invalid()
				),
				at(3) => {
					final fval = value._match(
						at(i is Integer) => i.int,
						at(f is Float) => f.float,
						_ => invalid()
					);
					time - (getSeconds(time) - fval);
				},
				_ => invalid()
			));
		}, {
			return getField(time, field);
		});
	}


	/*-- Scalar actions --*/

	// TODO: math ops + date

	override function even_q(value: Time) {
		var t = value.float;
		t = if(t >= 0) t + 1e-6 else t - 1e-6;
		return Logic.fromCond(Std.int(getSeconds(t)) & 1 == 0);
	}
	override function odd_q(value: Time) {
		var t = value.float;
		t = if(t >= 0) t + 1e-6 else t - 1e-6;
		return Logic.fromCond(Std.int(getSeconds(t)) & 1 != 0);
	}

	override function round(value: Time, options: ARoundOptions) {
		final ret = super.round(value, options);
		return if(ret is Time) ret else new Time(ret.asFloat());
	}


	/*-- Series actions --*/

	override function pick(value: Time, index: Value) {
		final idx = index._match(
			at(i is Integer) => i.int,
			at(w is Word) => getNamedIndex(w, value),
			_ => invalid()
		);
		if(idx < 1 || idx > 3) throw "out of range";
		return getField(value.float, idx);
	}
}