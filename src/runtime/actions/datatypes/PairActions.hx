package runtime.actions.datatypes;

import types.base._ActionOptions;
import types.base.MathOp;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Path;
import types.Value;
import types.Pair;
import types.Integer;
import types.Float;
import types.Percent;
import types.Money;
import types.Logic;
import types.None;
import types.Word;
import types.Block;

import runtime.actions.datatypes.ValueActions.invalid;

class PairActions extends ValueActions<Pair> {
	function getNamedIndex(w: Word, ref: Value): Int {
		final axis = w.symbol;
		if(axis != Words.X && axis != Words.Y) {
			if(ref is Pair) throw "cannot use";
			else throw "invalid path";
		}
		return if(axis == Words.X) 1 else 2;
	}

	
	override function make(proto: Null<Pair>, spec: Value) {
		return spec._match(
			at(i is Integer) => return new Pair(i.int, i.int),
			at(f is Float) => {
				final x = Std.int(f.float);
				return new Pair(x, x);
			},
			at(b is Block) => {
				if(b.length != 2) throw "syntax malconstruct";
				Util._match([b.fastPick(0), b.fastPick(1)],
					at([x is Integer | x is Float, y is Integer | y is Float]) => {
						return new Pair(x.asInt(), y.asInt());
					},
					_ => throw "syntax malconstruct"
				);
			},
			// String
			at(p is Pair) => return p,
			_ => invalid()
		);
	}
	
	override function to(proto: Null<Pair>, spec: Value) {
		return make(proto, spec);
	}

	override function evalPath(parent: Pair, element: Value, value: Null<Value>, path: _Path, isCase: Bool): Value {
		final axis = element._match(
			at(i is Integer) => {
				if(i.int != 1 && i.int != 2) throw "invalid path";
				i.int;
			},
			at(w is Word) => getNamedIndex(w, path),
			_ => throw "invalid path"
		);

		value._match(
			at(i is Integer) => {
				return if(axis == 1) new Pair(i.int, parent.y) else new Pair(parent.x, i.int);
			},
			at(null) => return new Integer(axis == 1 ? parent.x : parent.y),
			_ => invalid()
		);
	}
	
	override function compare(value1: Pair, value2: Value, op: ComparisonOp): CompareResult {
		final pair2 = value2._match(
			at(p is Pair) => p,
			_ => return IsInvalid
		);

		var diff = value1.x - pair2.x;
		if(diff == 0) diff = value1.y - pair2.y;
		return cast diff.sign();
	}

	override function doMath(left: Value, right: Value, op: MathOp) {
		final l = Std.downcast(left, Pair) ?? invalid();
		
		var x = 0;
		var y = 0;
		right._match(
			at(r is Pair) => {
				x = r.x;
				y = r.y;
			},
			at(r is Integer) => {
				x = y = r.int;
			},
			at(r is Float | r is Percent) => {
				final f = r.float;
				if(!Math.isFinite(f)) invalid();
				op._match(
					at(OMul) => return new Pair(Std.int(l.x * f), Std.int(l.y * f)),
					at(ODiv) => return new Pair(Std.int(l.x / f), Std.int(l.y / f)),
					_ => {
						x = y = Std.int(f);
					}
				);
			},
			_ => invalid()
		);
		return new Pair(
			Std.int(IntegerActions.doMathOp(l.x, x, op, true)),
			Std.int(IntegerActions.doMathOp(l.y, y, op, true))
		);
	}


	/*-- Scalar actions --*/

	override function absolute(value: Pair) {
		return new Pair(Math.iabs(value.x), Math.iabs(value.y));
	}

	override function negate(value: Pair) {
		return new Pair(-value.x, -value.y);
	}

	override function add(value1: Pair, value2: Value) {
		return doMath(value1, value2, OAdd);
	}

	override function subtract(value1: Pair, value2: Value) {
		return doMath(value1, value2, OSub);
	}

	override function multiply(value1: Pair, value2: Value) {
		return doMath(value1, value2, OMul);
	}

	override function divide(value1: Pair, value2: Value) {
		return doMath(value1, value2, ODiv);
	}

	override function remainder(value1: Pair, value2: Value) {
		return doMath(value1, value2, ORem);
	}

	override function round(value: Pair, options: ARoundOptions) {
		final scale = options.to?.scale;
		if(scale is Money) throw "not related";

		var y = 0;
		final scalexy = scale._match(
			at(p is Pair) => {
				y = p.y;
				options.to.scale = new Integer(p.x);
				true;
			},
			_ => false
		);

		final res = new Pair(0, 0);
		final intActions = Actions.get(DInteger);

		res.x = (cast intActions.round(new Integer(value.x), options) : Integer).int;

		if(scalexy) (untyped options.to.scale).int = y;
		res.y = (cast intActions.round(new Integer(value.y), options) : Integer).int;

		return res;
	}


	/*-- Bitwise actions --*/

	override function and(value1: Pair, value2: Value) {
		return doMath(value1, value2, OAnd);
	}

	override function or(value1: Pair, value2: Value) {
		return doMath(value1, value2, OOr);
	}

	override function xor(value1: Pair, value2: Value) {
		return doMath(value1, value2, OXor);
	}


	/*-- Series actions --*/

	override function pick(value: Pair, index: Value) {
		final idx = index._match(
			at(i is Integer) => i.int,
			at(w is Word) => getNamedIndex(w, value),
			_ => invalid()
		);
		if(idx != 1 && idx != 2) throw "out of range";
		return new Integer(idx == 1 ? value.x : value.y);
	}

	override function reverse(value: Pair, options: AReverseOptions) {
		return new Pair(value.y, value.x);
	}
}