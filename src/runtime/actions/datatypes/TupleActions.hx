package runtime.actions.datatypes;

import util.UInt8ClampedArray;

import types.base.MathOp;
import types.base._ActionOptions;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Path;
import types.base._Block;
import types.base._Integer;
import types.Value;
import types.Tuple;
import types.Integer;
import types.Char;
import types.Float;
import types.Percent;
import types.Logic;
import types.None;

import runtime.actions.datatypes.ValueActions.invalid;

class TupleActions extends ValueActions<Tuple> {
	override function make(proto: Null<Tuple>, spec: Value) {
		return to(proto, spec);
	}

	override function to(proto: Null<Tuple>, spec: Value) {
		return spec._match(
			at(b is _Block) => {
				final n = b.length;
				if(n > 12) invalid();
				final tp = new UInt8ClampedArray(n.max(3));
				for(i => v in b) {
					tp[i] = v._match(
						at(i is _Integer) => i.int,
						at(f is Float) => cast f.float,
						_ => invalid()
					);
				}
				new Tuple(tp);
			},
			// Binary
			// Issue
			// _String
			at(t is Tuple) => t,
			_ => invalid()
		);
	}

	override function evalPath(parent: Tuple, element: Value, value: Null<Value>, path: _Path, isCase: Bool): Value {
		element._match(
			at(i is Integer) => {
				value._andOr(value => {
					var index = i.int;
					var tp = parent.values;
					var size = tp.length;
					
					if(index <= 0 || index > size) throw "out of range";

					value._match(
						at(v is Integer) => {
							tp = tp.slice();
							tp[index - 1] = v.int;
						},
						at(_ is None) => {
							size = index > 3 ? index - 1 : 3;
							tp = tp.slice(0, size);
							if(index < 3) tp.fill(0, index - 1);
						},
						_ => invalid()
					);

					return new Tuple(tp);
				}, {
					return pick(parent, i);
				});
			},
			_ => invalid()
		);
	}

	override function compare(value1: Tuple, value2: Value, op: ComparisonOp): CompareResult {
		final tuple2 = value2._match(
			at(t is Tuple) => t,
			_ => return IsInvalid
		);

		final t1 = value1.values;
		final t2 = tuple2.values;
		final sz1 = t1.length;
		final sz2 = t2.length;
		final sz = sz1.max(sz2);

		for(i in 0...sz) {
			final v1 = i >= sz1 ? 0 : t1[i];
			final v2 = i >= sz2 ? 0 : t2[i];

			if(v1 != v2) {
				return cast v1.compare(v2);
			}
		}

		return IsSame;
	}

	override function doMath(left: Value, right: Value, op: MathOp) {
		var isSwap = false;
		final l = left._match(
			at(t is Tuple) => t,
			_ => {
				if(op == OSub || op == ODiv) throw "not related";
				isSwap = true;
				Util.swap(left, right);
				(cast left : Tuple);
			}
		);

		var isFloat = false;
		var size2 = 0;
		var tp2: UInt8ClampedArray = null;
		var v = 0;
		var f2 = 0.0;
		right._match(
			at(r is Tuple) => {
				tp2 = r.values;
				size2 = tp2.length;
			},
			at(r is Integer) => {
				v = r.int;
			},
			at(r is Float | r is Percent) => {
				isFloat = true;
				f2 = r.float;
			},
			_ => invalid()
		);

		var tp1 = l.values;
		var size1 = tp1.length;
		if(isFloat) {
			tp1 = tp1.slice();
			for(n in 0...size1) {
				tp1[n] = cast FloatActions.doMathOp(tp1[n], f2, op);
			}
		} else {
			var size: Int;
			if(size1 < size2) {
				tp1 = new UInt8ClampedArray(size2);
				tp1.setAll(l.values);
				size = size2;
			} else {
				tp1 = tp1.slice();
				size = size1;
			}
			for(n in 0...size) {
				if(size2 != 0) {
					v = if(n < size2) tp2[n] else 0;
				}
				final v1 = if(n < size1) tp1[n] else 0;
				tp1[n] = cast IntegerActions.doMathOp(v1, v, op, true);
			}
		}
		
		return new Tuple(tp1);
	}


	/*-- Scalar actions --*/

	override function add(value1: Tuple, value2: Value) {
		return doMath(value1, value2, OAdd);
	}

	override function subtract(value1: Tuple, value2: Value) {
		return doMath(value1, value2, OSub);
	}

	override function multiply(value1: Tuple, value2: Value) {
		return doMath(value1, value2, OMul);
	}

	override function divide(value1: Tuple, value2: Value) {
		return doMath(value1, value2, ODiv);
	}

	override function remainder(value1: Tuple, value2: Value) {
		return doMath(value1, value2, ORem);
	}


	/*-- Bitwise actions --*/

	override function complement(value: Tuple) {
		return new Tuple(value.values.map(v -> ~v + 256));
	}

	override function and(value1: Tuple, value2: Value) {
		return doMath(value1, value2, OAnd);
	}

	override function or(value1: Tuple, value2: Value) {
		return doMath(value1, value2, OOr);
	}

	override function xor(value1: Tuple, value2: Value) {
		return doMath(value1, value2, OXor);
	}


	/*-- Series actions --*/

	override function length_q(tuple: Tuple) {
		return new Integer(tuple.values.length);
	}

	override function pick(tuple: Tuple, index: Value) {
		final idx = index._match(
			at(i is Integer) => i.int,
			_ => invalid()
		);

		final size = tuple.values.length;

		if(idx <= 0 || idx > size) {
			throw "out of range";
		} else {
			return new Integer(tuple.values[idx - 1]);
		}
	}

	override function reverse(tuple: Tuple, options: AReverseOptions) {
		final tp = tuple.values;

		var size = tp.length;
		var part = size;
		var skip = 1;

		options.part._match(
			at(null) => {},
			at({length: i is Integer}) => {
				part = i.int;
				if(part < 0) throw "out of range";
			},
			_ => invalid()
		);

		options.skip._match(
			at(null) => {},
			at({size: i}) => {
				skip = i.int;

				if(skip == part) return tuple;
				if(skip <= 0) throw "out of range";
				if(skip > part || part % skip != 0) invalid();
			}
		);

		//if(part < size) size = part;

		if(skip == 1) {
			// TODO: eventually use TypedArray#toReversed() once it's widespread
			if(part == size) {
				return new Tuple(tp.slice().reverse());
			} else {
				final res = tuple.values.slice();
				res.subarray(0, part).reverse();
				return new Tuple(res);
			}
		} else {
			if(part < size) size = part;

			final res = tp.slice();

			var temp = new UInt8ClampedArray(skip);
			var head = 0;
			var tail = size - skip;

			while(head < tail) {
				/// do this better with less allocations somehow
				temp.setAll(res.subarray(head, head + skip));
				res.copyWithin(head, tail, tail + skip);
				res.setAll(temp, tail);

				head += skip;
				tail -= skip;
			}

			return new Tuple(res);
		}
	}
}