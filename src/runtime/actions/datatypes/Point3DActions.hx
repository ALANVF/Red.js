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

class Point3DActions extends ValueActions<Point3D> {
	static function getNamedIndex(w: Word, ref: Value): Int {
		final axis = w.symbol;
		if(axis != Words.X && axis != Words.Y && axis != Words.Z) {
			if(ref is Pair) throw "cannot use";
			else throw "invalid path";
		}
		return if(axis == Words.X) 1 else if(axis == Words.Y) 2 else 3;
	}

	override function make(proto: Null<Point3D>, spec: Value) {
		return spec._match(
			at(i is Integer) => new Point3D(i.int, i.int, i.int),
			at(f is Float) => new Point3D(f.float, f.float, f.float),
			at(b is Block) => {
				if(b.length >= 3) {
					final x = b.fastPick(0)._match(
						at({int: (_:StdTypes.Float)=>n} is Integer | {float: n} is Float) => n,
						_ => throw "bad"
					);
					final y = b.fastPick(1)._match(
						at({int: (_:StdTypes.Float)=>n} is Integer | {float: n} is Float) => n,
						_ => throw "bad"
					);
					final z = b.fastPick(2)._match(
						at({int: (_:StdTypes.Float)=>n} is Integer | {float: n} is Float) => n,
						_ => throw "bad"
					);
					return new Point3D(x, y, z);
				} else throw "bad";
			},
			at(p is Pair) => new Point3D(p.x, p.y, 0.0),
			at(p is Point2D) => new Point3D(p.x, p.y, 0.0),
			// String
			at(p is Point3D) => p,
			_ => throw "bad"
		);
	}

	override function form(value: Point3D, buffer: String, arg: Null<Int>, part: Int) {
		buffer.appendChar('('.code);
		var formed = value.x.toString();
		buffer.appendLiteral(formed);
		part -= formed.length;

		buffer.appendLiteral(", ");

		formed = value.y.toString();
		buffer.appendLiteral(formed);

		buffer.appendLiteral(", ");

		formed = value.z.toString();
		buffer.appendLiteral(formed);

		buffer.appendChar(')'.code);
		return part - 6 - formed.length;
	}

	override function mold(value: Point3D, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		return form(value, buffer, arg, part);
	}

	override function evalPath(
		parent: Point3D, element: Value, value: Null<Value>,
		path: Null<_Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	): Value {
		final axis = element._match(
			at(i is Integer) => {
				if(i.int != 1 && i.int != 2 && i.int != 3) throw "invalid path";
				i.int;
			},
			at(w is Word) => getNamedIndex(w, path),
			_ => throw "invalid path"
		);

		value._match(
			at(i is Integer) => {
				return if(axis == 1) new Point3D(i.int, parent.y, parent.z)
					else if(axis == 2) new Point3D(parent.x, i.int, parent.z)
					else new Point3D(parent.x, parent.y, i.int);
			},
			at(f is Float) => {
				return if(axis == 1) new Point3D(f.float, parent.y, parent.z)
					else if(axis == 2) new Point3D(parent.x, f.float, parent.z)
					else new Point3D(parent.x, parent.y, f.float);
			},
			at(null) => return new Float(axis == 1 ? parent.x : axis == 2 ? parent.y : parent.z),
			_ => invalid()
		);
	}

	// TODO: implement actual float cmp
	override function compare(value1: Point3D, value2: Value, op: ComparisonOp): CompareResult {
		final point2 = value2._match(
			at(p is Point3D) => p,
			_ => return IsInvalid
		);

		var diff = value1.x - point2.x;
		if(diff == 0) {
			diff = value1.y - point2.y;
			if(diff == 0) diff = value1.z - point2.z;
		}
		return cast diff.sign();
	}

	override function doMath(left: Value, right: Value, op: MathOp) {
		left._match(
			at(l is Point3D) => {
				var x, y, z;
				right._match(
					at(p is Point3D) => {
						x = p.x;
						y = p.y;
						z = p.z;
					},
					at(i is Integer) => {
						x = y = z = i.int;
					},
					at({float: f} is _Float) => {
						op._match(
							at(OMul) => {
								return new Point3D(l.x * f, l.y / f, l.z * f);
							},
							at(ODiv) => {
								return new Point3D(l.x * f, l.y / f, l.z / f);
							},
							_ => {
								x = y = z = f;
							}
						);
					},
					_ => invalid()
				);
				return new Point3D(
					FloatActions.doMathOp(l.x, x, op),
					FloatActions.doMathOp(l.y, y, op),
					FloatActions.doMathOp(l.z, z, op)
				);
			},
			_ => invalid()
		);
	}

	/*-- Scalar actions --*/
	
	override function absolute(value: Point3D) {
		return new Point3D(Math.abs(value.x), Math.abs(value.y), Math.abs(value.z));
	}

	override function negate(value: Point3D) {
		return new Point3D(-value.x, -value.y, -value.z);
	}
	
	override function add(value1: Point3D, value2: Value) {
		return doMath(value1, value2, OAdd);
	}

	override function subtract(value1: Point3D, value2: Value) {
		return doMath(value1, value2, OSub);
	}

	override function multiply(value1: Point3D, value2: Value) {
		return doMath(value1, value2, OMul);
	}

	override function divide(value1: Point3D, value2: Value) {
		return doMath(value1, value2, ODiv);
	}

	override function remainder(value1: Point3D, value2: Value) {
		return doMath(value1, value2, ORem);
	}

	override function round(value: Point3D, options: ARoundOptions) {
		final scale = options.to?.scale;
		if(scale is Money) throw "not related";

		var y = 0.0;
		var z = 0.0;
		final scalexy = scale._match(
			at(p is Point3D) => {
				y = p.y;
				z = p.z;
				options.to.scale = new Float(p.x);
				true;
			},
			_ => false
		);

		final floatActions = Actions.get(DFloat);

		final rx = (cast floatActions.round(new Float(value.x), options) : Float).float;

		if(scalexy) options.to.scale = new types.Float(y);
		final ry = (cast floatActions.round(new Float(value.y), options) : Float).float;
		
		if(scalexy) options.to.scale = new types.Float(z);
		final rz = (cast floatActions.round(new Float(value.z), options) : Float).float;
		
		return new Point3D(rx, ry, rz);
	}

	/*-- Series actions --*/

	override function pick(value: Point3D, index: Value) {
		final idx = index._match(
			at(i is Integer) => i.int,
			at(w is Word) => getNamedIndex(w, value),
			_ => invalid()
		);
		if(idx != 1 && idx != 2 && idx != 3) throw "out of range";
		return new Float(idx == 1 ? value.x : idx == 2 ? value.y : value.z);
	}

	override function reverse(value: Point3D, options: AReverseOptions) {
		return new Point3D(value.z, value.y, value.x);
	}
}