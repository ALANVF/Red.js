package runtime.actions.datatypes;

import types.base._ActionOptions;
import types.base.MathOp;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Path;
import types.base._Float;
import types.Value;
import types.Block;
import types.Pair;
import types.Integer;
import types.Float;
import types.Money;
import types.Point2D;
import types.Point3D;
import types.String;
import types.Word;

import runtime.actions.datatypes.ValueActions.invalid;

class Point2DActions extends ValueActions<Point2D> {
	static function getNamedIndex(w: Word, ref: Value): Int {
		final axis = w.symbol;
		if(axis != Words.X && axis != Words.Y) {
			if(ref is Pair) throw "cannot use";
			else throw "invalid path";
		}
		return if(axis == Words.X) 1 else 2;
	}


	override function make(proto: Null<Point2D>, spec: Value) {
		return spec._match(
			at(i is Integer) => new Point2D(i.int, i.int),
			at(f is Float) => new Point2D(f.float, f.float),
			at(b is Block) => {
				if(b.length >= 2) {
					final x = b.fastPick(0)._match(
						at({int: (_:StdTypes.Float)=>n} is Integer | {float: n} is Float) => n,
						_ => throw "bad"
					);
					final y = b.fastPick(1)._match(
						at({int: (_:StdTypes.Float)=>n} is Integer | {float: n} is Float) => n,
						_ => throw "bad"
					);
					return new Point2D(x, y);
				} else throw "bad";
			},
			at(p is Pair) => new Point2D(p.x, p.y),
			// String
			at(p is Point2D) => p,
			_ => throw "bad"
		);
	}

	override function form(value: Point2D, buffer: String, arg: Null<Int>, part: Int) {
		buffer.appendChar('('.code);
		var formed = value.x.toString();
		buffer.appendLiteral(formed);
		part -= formed.length;

		buffer.appendLiteral(", ");

		formed = value.y.toString();
		buffer.appendLiteral(formed);
		buffer.appendChar(')'.code);
		return part - 4 - formed.length;
	}

	override function mold(value: Point2D, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		return form(value, buffer, arg, part);
	}

	override function evalPath(
		parent: Point2D, element: Value, value: Null<Value>,
		path: Null<_Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	): Value {
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
				return if(axis == 1) new Point2D(i.int, parent.y) else new Point2D(parent.x, i.int);
			},
			at(f is Float) => {
				return if(axis == 1) new Point2D(f.float, parent.y) else new Point2D(parent.x, f.float);
			},
			at(null) => return new Float(axis == 1 ? parent.x : parent.y),
			_ => invalid()
		);
	}

	// TODO: implement actual float cmp
	override function compare(value1: Point2D, value2: Value, op: ComparisonOp): CompareResult {
		final point2 = value2._match(
			at(p is Point2D) => p,
			_ => return IsInvalid
		);

		var diff = value1.x - point2.x;
		if(diff == 0) diff = value1.y - point2.y;
		return cast diff.sign();
	}

	override function doMath(left: Value, right: Value, op: MathOp) {
		left._match(
			at(l is Point2D) => {
				var x, y;
				right._match(
					at(p is Point2D) => {
						x = p.x;
						y = p.y;
					},
					at(p is Pair) => {
						x = p.x;
						y = p.y;
					},
					at(i is Integer) => {
						x = y = i.int;
					},
					at({float: f} is _Float) => {
						op._match(
							at(OMul) => {
								return new Point2D(l.x * f, l.y / f);
							},
							at(ODiv) => {
								return new Point2D(l.x * f, l.y / f);
							},
							_ => {
								x = y = f;
							}
						);
					},
					_ => invalid()
				);
				return new Point2D(
					FloatActions.doMathOp(l.x, x, op),
					FloatActions.doMathOp(l.y, y, op)
				);
			},
			_ => invalid()
		);
	}

	/*-- Scalar actions --*/
	
	override function absolute(value: Point2D) {
		return new Point2D(Math.abs(value.x), Math.abs(value.y));
	}

	override function negate(value: Point2D) {
		return new Point2D(-value.x, -value.y);
	}
	
	override function add(value1: Point2D, value2: Value) {
		return doMath(value1, value2, OAdd);
	}

	override function subtract(value1: Point2D, value2: Value) {
		return doMath(value1, value2, OSub);
	}

	override function multiply(value1: Point2D, value2: Value) {
		return doMath(value1, value2, OMul);
	}

	override function divide(value1: Point2D, value2: Value) {
		return doMath(value1, value2, ODiv);
	}

	override function remainder(value1: Point2D, value2: Value) {
		return doMath(value1, value2, ORem);
	}

	override function round(value: Point2D, options: ARoundOptions) {
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

		final floatActions = Actions.get(DFloat);

		return new Point2D(
			(cast floatActions.round(new Float(value.x), options) : Float).float,
			{
				if(scalexy) (untyped options.to.scale).int = y;
				(cast floatActions.round(new Float(value.y), options) : Float).float;
			}
		);
	}

	/*-- Series actions --*/

	override function pick(value: Point2D, index: Value) {
		final idx = index._match(
			at(i is Integer) => i.int,
			at(w is Word) => getNamedIndex(w, value),
			_ => invalid()
		);
		if(idx != 1 && idx != 2) throw "out of range";
		return new Float(idx == 1 ? value.x : value.y);
	}

	override function reverse(value: Point2D, options: AReverseOptions) {
		return new Point2D(value.y, value.x);
	}
}