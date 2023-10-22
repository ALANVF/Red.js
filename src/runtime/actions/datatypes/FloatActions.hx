package runtime.actions.datatypes;

import types.base.MathOp;
import types.base._ActionOptions;
import types.base.ComparisonOp;
import types.base.CompareResult;
import types.base._Number;
import types.base._Integer;
import types.base._Float;
import types.base._Block;
import types.Value;
import types.Integer;
import types.Float;
import types.Money;
import types.Time;
import types.Percent;
import types.Logic;
import types.Char;
import types.Pair;
import types.Tuple;
import types.String;

import runtime.actions.datatypes.ValueActions.invalid;

class FloatActions<This: _Float = Float> extends ValueActions<This> {
	private function makeThis(f: StdTypes.Float): This {
		return cast new Float(f);
	}

	static function formFloat(f: _Float) {
		var d = f.float;

		if(d == Math.NaN) return "1.#NaN";
		else if(d == Math.NEGATIVE_INFINITY) return "-1.#Inf";
		else if(d == Math.POSITIVE_INFINITY) return "1.#Inf";

		final isPercent = f is Percent;
		
		// TODO
		
		if(isPercent) d *= 100;
		var s = d.toString();
		if(isPercent) s += "%";
		else if(!s.includes(".")) s += ".0";
		return s;
	}
	

	override function make(proto: Null<This>, spec: Value) {
		return to(proto, spec);
	}

	override function to(proto: Null<This>, spec: Value) {
		return spec._match(
			at(i is _Integer) => makeThis(i.int),
			// Money
			at(f is _Float) => makeThis(f.float),
			at(s is types.base._String) => Tokenizer.parse(s.toJs())._match(
				at([f is Float | f is Percent]) => f, // lazy for now lol
				_ => throw 'Can\'t parse float! from "${s.toJs()}"'
			),
			// Binary
			at(b is _Block) => {
				if(b.length != 2) invalid();
				b.fastPick(0)._match(
					at(n is Float | n is Integer) => {
						b.fastPick(1)._match(
							at(i is Integer) => makeThis(n.asFloat() * Math.pow(10, i.int)),
							_ => invalid()
						);
					},
					_ => invalid()
				);
			},
			_ => invalid()
		);
	}

	override function form(value: This, buffer: String, _, part: Int) {
		final formed = formFloat(value);
		buffer.appendLiteral(formed);
		return part - formed.length;
	}

	override function mold(value: This, buffer: String, _, _, _, _, part: Int, _) {
		final str = switch value.float {
			// TODO: force this as a js switch because this does not generate an actual switch
			case _ == Math.NaN => true: "1.#NaN";
			case _ == Math.POSITIVE_INFINITY => true: "1.#Inf";
			case _ == Math.NEGATIVE_INFINITY => true: "-1.#Inf";
			case f: {
				final s = f.toString();
				if(s.includes(".")) s else s + ".0";
			}
		};
		buffer.appendLiteral(str);
		return part - str.length;
	}
	
	// TODO: implement actual float comparison:
	// - the yucky R/S code: https://github.com/red/red/blob/master/runtime/datatypes/float.reds#L669
	// - possible impl behavior: https://replit.com/@theangryepicbanana/FloweryAdventurousMicrobsd
	override function compare(value1: This, value2: Value, op: ComparisonOp) {
		if((op == CFind || op == CStrictEqual) && !(value2.thisType() == value1.thisType())) {
			return IsMore;
		}
		
		final other = value2._match(
			at(i is _Integer) => i.int,
			at(_ is Money) => throw "todo!",
			at(f is _Float) => f.float,
			// ...
			_ => return IsInvalid
		);
		
		final f = value1.float;
		
		op._match(
			at(CEqual | CNotEqual) => {
				return if(Math.isNaN(f) || Math.isNaN(other)) {
					IsMore;
				} else if(f < other) {
					IsLess;
				} else if(f > other) {
					IsMore;
				} else {
					IsSame;
				}
			},
			at(CStrictEqual) => {
				return if(f == other) IsSame else IsMore;
			},
			at(CSame) => {
				return if((Math.isNaN(f) && Math.isNaN(other)) || f == other) IsSame else IsMore;
			},
			_ => {
				return if(f < other) {
					IsLess;
				} else if(f > other) {
					IsMore;
				} else {
					IsSame;
				}
			}
		);
	}

	static function doMathOp(left: StdTypes.Float, right: StdTypes.Float, op: MathOp) {
		return op._match(
			at(OAdd) => left + right,
			at(OSub) => left - right,
			at(OMul) => left * right,
			at(ODiv) => left / right,
			at(ORem) =>  left % right,
			_ => invalid()
		);
	}

	override function doMath(left: Value, right: Value, op: MathOp) {
		if(!(left is _Number)) invalid();

		right._match(
			at(_ is Tuple) => return Actions.get(DTuple).doMath(left, right, op),
			// Money
			at(_ is Pair, when(!(left is Time))) => {
				if(op == OSub || op == ODiv) throw "not related";
				return Actions.get(DPair).doMath(right, left, op);
			},
			// Vector
			_ => {}
		);

		if(!(right is _Number) || ((left is Time || left is Percent) && right is Char)) invalid();
		
		final isPct = left is Percent && !(right is Percent);

		final op1 = (cast left : _Number).asFloat();
		final op2 = (cast right : _Number).asFloat();

		final isT1 = left is Time && !(right is Time);
		final isT2 = !(left is Time) && right is Time;

		final res = doMathOp(op1, op2, op);

		return (
			if(isT1 || isT2) new Time(res)
			else if(isPct && !isT2) new Percent(res)
			else makeThis(res)
		);
	}
	
	
	/*-- Scalar actions --*/
	
	override function absolute(value: This) {
		return makeThis(Math.abs(value.float));
	}

	override function negate(value: This) {
		return makeThis(-value.float);
	}

	override function add(value1: This, value2: Value) {
		return doMath(value1, value2, OAdd);
	}

	override function subtract(value1: This, value2: Value) {
		return doMath(value1, value2, OSub);
	}

	override function multiply(value1: This, value2: Value) {
		return doMath(value1, value2, OMul);
	}

	override function divide(value1: This, value2: Value) {
		return doMath(value1, value2, ODiv);
	}

	override function remainder(value1: This, value2: Value) {
		return doMath(value1, value2, ORem);
	}

	override function power(number: This, exponent: _Number) {
		final exp = exponent._match(
			at(i is Integer) => (i.int : StdTypes.Float),
			at(f is Float) => f.float,
			_ => invalid()
		);

		return makeThis(Math.pow(number.float, exp));
	}

	override function even_q(value: This) {
		return Logic.fromCond(Std.int(value.float) & 1 == 0);
	}

	override function odd_q(value: This) {
		return Logic.fromCond(Std.int(value.float) & 1 != 0);
	}

	// TODO: fix when using any-float! below 1.0 as scale, why doesn't it work?????
	override function round(value: This, options: ARoundOptions): _Number {
		final scale = options.to?.scale;
		
		var e = 0;
		var dec = value.float;
		var sc = value is Percent ? 0.01 : 1.0;
		scale._match(
			at(null) => {},
			at(_ is Money) => throw "not related",
			at(i is Integer) => {
				sc = Math.abs(i.int);
				if(value is Percent) sc /= 100;
			},
			at(f is _Float) => {
				sc = Math.abs(f.float);
				if(value is Percent) sc /= 100;
			},
			_ => invalid()
		);
		if(sc < Math.ldexp(Math.abs(dec), -53)) return value;

		final v = sc >= 1.0;
		dec = if(v) dec / sc else {
			Util.detuple([@var r, e], Math.frexp(sc));
			if(e <= -1022) {
				sc = r;
				dec = Math.ldexp(dec, e);
			} else {
				e = 0;
			}
			sc = 1.0 / sc;
			dec * sc;
		};

		final d = Math.abs(dec);
		final r = 0.5 + Math.floor(d);
		dec = (
			if(options.down) Math.trunc(dec)
			else if(options.floor) Math.floor(dec)
			else if(options.ceiling) Math.ceil(dec)
			else if(r < d) Math.away(dec)
			else if(r > d) Math.trunc(dec)
			else if(options.even) (d % 2.0 < 1.0 ? Math.trunc(dec) : Math.away(dec))
			else if(options.halfDown) Math.trunc(dec)
			else if(options.halfCeiling) Math.ceil(dec)
			else Math.away(dec)
		);
		
		final f = if(v) {
			dec *= sc;
			// TODO: if(DOUBLE_MAX == Math.abs(dec)) throw "math overflow";
			dec;
		} else {
			Math.ldexp(dec / sc, e);
		};
		return scale._match(
			at(null) => makeThis(f),
			at(_ is Integer) => new Integer(Std.int(dec)),
			_ => (cast scale : _Float).make(dec)
		);
	}
}