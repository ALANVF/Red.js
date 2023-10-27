package runtime.actions.datatypes;

import util.BigInt;
import util.Dec64;

import types.base._ActionOptions;
import types.base.MathOp;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Float;
import types.base._String;
import types.base._Path;
import types.Value;
import types.Money;
import types.Integer;
import types.Float;
import types.Percent;
import types.Money;
import types.Logic;
import types.None;
import types.Word;
import types.Block;
import types.String;

import runtime.actions.datatypes.ValueActions.invalid;

class MoneyActions extends ValueActions<Money> {
	static function getNamedIndex(w: Word, ref: Value): Int {
		final axis = w.symbol;
		if(axis != Words.AMOUNT && axis != Words.CODE) {
			if(ref is Money) throw "cannot use";
			else throw "invalid path";
		}
		return if(axis == Words.AMOUNT) 1 else 2;
	}

	static function fromInteger(i: Integer, ?region: Word) {
		return new Money(Dec64.of(i.int, 0), region);
	}
	static function fromInt(i: Int, ?region: Word) {
		return new Money(Dec64.of(i, 0), region);
	}

	static function fromFloat(f: _Float, ?region: Word) {
		final fl = f.float;
		// TODO: check to make sure decimal digits are <= 5
		if(!Math.isFinite(fl) || floatOverflow(fl) || floatUnderflow(fl)) invalid();
		return new Money(Dec64.fromDouble(fl), region);
	}
	
	static function fromString(s: _String) {
		return Tokenizer.parse(s.toJs())._match(
			at([m is Money]) => m,
			at([i is Integer]) => fromInteger(i),
			at([f is Float]) => fromFloat(f),
			_ => throw 'Can\'t parse tuple! from "${s.toJs()}"'
		);
	}

	static inline function floatOverflow(f: StdTypes.Float) {
		return Math.abs(f) >= 1e17;
	}

	static inline function floatUnderflow(f: StdTypes.Float) {
		f = Math.abs(f);
		return f > 0 && f < 1e-5;
	}

	static function sameRegion(l: Money, r: Money, strict: Bool) {
		final c1 = l.region;
		final c2 = r.region;
		return (!strict && (c1 == null || c2 == null)) || c1?.symbol == c2?.symbol;
	}

	static function sortMoney(l: Money, r: Money) {
		final c1 = l.region;
		final c2 = r.region;

		final flag = if(js.Syntax.code("{0}?.constructor == {1}?.constructor", c1, c2)) {
			if(c1 == null) IsSame else Actions.get(DWord).compare(c1, c2, CLesser);
		} else {
			if(c1 == null) IsLess else IsMore;
		};

		return if(flag == IsSame) compareMoney(l, r) else flag;
	}

	static function compareMoney(l: Money, r: Money): CompareResult {
		return cast l.m.compare(r.m);
	}

	static function doMathOp(left: Dec64, right: Dec64, op: MathOp) {
		return op._match(
			at(OAdd) => left + right,
			at(OSub) => left - right,
			at(OMul) => left * right,
			at(ODiv) => left / right,
			at(ORem) => left % right,
			_ => throw "bad"
		);
	}


	override function make(proto: Null<Money>, spec: Value) {
		return spec._match(
			at(w is Word) => new Money(Dec64.ZERO, w),
			at(b is Block) => {
				// I don't quite understand what's going on in Red's impl,
				// so we'll just keep it simple for now
				if(b.length < 1) invalid();
				var i = 0;
				var region = null;
				b.rawFastPick(i)._match(
					at(w is Word) => {
						region = w;
						i++;
						if(b.length < 2) invalid();
					},
					_ => {}
				);
				b.rawFastPick(i)._match(
					at(f is Float) => fromFloat(f, region),
					at(i1 is Integer) => {
						i++;
						if(b.length < i + 1) fromInteger(i1, region)
						else b.rawFastPick(i)._match(
							at(i2 is Integer) => {
								final int1 = i1.int;
								final int2 = i2.int;
								if(int2 < 0) invalid();
								// lazy for now
								final s = int2.toString().padStart(5, "0");
								if(s.length > 5) invalid();
								new Money(Dec64.fromString('$int1.$s'), region);
							},
							_ => invalid()
						);
					},
					_ => invalid()
				);
			},
			_ => to(proto, spec)
		);
	}

	override function to(proto: Null<Money>, spec: Value) {
		return spec._match(
			at(m is Money) => m,
			at(i is Integer) => fromInteger(i),
			at(f is Float) => fromFloat(f),
			at(s is _String) => fromString(s),
			_ => invalid()
		);
	}

	override function evalPath(
		parent: Money, element: Value, value: Null<Value>,
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
			at(null) => return (
				if(axis == 1) new Money(parent.m, null)
				else parent.region ?? cast None.NONE
			),
			_ => invalid()
		);
	}

	override function compare(value1: Money, value2: Value, op: ComparisonOp): CompareResult {
		var strict = op == CStrictEqual || op == CSame || op == CFind;
		if(strict && !(value2.thisType() == value1.thisType())) {
			return IsMore;
		}

		final value = value2._match(
			at(m is Money) => op._match(
				at(CSort | CCaseSort) => return sortMoney(value1, m),
				at(CLesser | CLesserEqual | CGreater | CGreaterEqual) => {
					if(!sameRegion(value1, m, false)) throw "wrong denomination";
					m;
				},
				_ => {
					if(op == CFind) strict = value1.region != null;
					if(!sameRegion(value1, m, strict)) return IsMore;
					else m;
				}
			),
			at(i is Integer) => fromInteger(i),
			at(f is Float) => {
				if(floatUnderflow(f.float)) return IsMore;
				if(floatOverflow(f.float)) return IsLess;
				fromFloat(f);
			},
			_ => invalid()
		);

		return compareMoney(value1, value);
	}

	override function form(value: Money, buffer: String, arg: Null<Int>, part: Int) {
		var res = value.m.toFixed(2);
		final neg = res.startsWith("-");
		res = "$" + (neg ? res._substr(1) : res);
		value.region._and(r => {
			res = r.symbol.name + res;
		});
		if(neg) res = "-" + res;
		if(arg != null && res.length > part) res = res._substr(0, part);
		
		buffer.appendLiteral(res);

		return part - res.length;
	}

	override function mold(value: Money, buffer: String, _, isAll: Bool, _, arg: Null<Int>, part: Int, _) {
		var res = value.m.toFixed(isAll ? 5 : 2);
		final neg = res.startsWith("-");
		res = "$" + (neg ? res._substr(1) : res);
		value.region._and(r => {
			res = r.symbol.name + res;
		});
		if(neg) res = "-" + res;
		if(arg != null && res.length > part) res = res._substr(0, part);

		buffer.appendLiteral(res);

		return part - res.length;
	}

	override function doMath(left: Value, right: Value, op: MathOp): Value {
		final l = left._match(
			at(m is Money) => m,
			at(i is Integer) => fromInteger(i),
			at(f is _Float) => fromFloat(f),
			_ => throw "bad"
		);

		final r = right._match(
			at(m is Money) => m,
			at(i is Integer) => fromInteger(i),
			at(f is _Float) => fromFloat(f),
			_ => throw "bad"
		);

		if(l.region != null && r.region != null && l.region != r.region) {
			throw "wrong denomination";
		}

		final result = doMathOp(l.m, r.m, op);
		if(op == ODiv && left is Money && right is Money) {
			return new Float(result.toDouble());
		} else {
			return new Money(result, l.region ?? r.region);
		}
	}

	
	/*-- Scalar actions --*/

	override function absolute(value: Money) {
		return new Money(value.m.abs(), value.region);
	}

	override function negate(value: Money) {
		return new Money(-value.m, value.region);
	}

	override function add(value1: Money, value2: Value) {
		return doMath(value1, value2, OAdd);
	}

	override function subtract(value1: Money, value2: Value) {
		return doMath(value1, value2, OSub);
	}

	override function multiply(value1: Money, value2: Value) {
		return doMath(value1, value2, OMul);
	}

	override function divide(value1: Money, value2: Value) {
		return doMath(value1, value2, ODiv);
	}

	override function remainder(value1: Money, value2: Value) {
		return doMath(value1, value2, ORem);
	}

	override function round(value: Money, options: ARoundOptions) {
		final sign = value.m.sign();
		if(sign == 0) return value;

		final scale = (options.to?.scale)._andOr(scale => scale._match(
			at(m is Money) => m,
			at(i is Integer) => fromInteger(i),
			// this does not work properly and idk why. it just spits out random ass values
			at(f is Float) => throw 'NYI',//fromFloat(f),
			_ => invalid()
		), fromInt(1));

		if(scale.m.isZero()) return value;
		value = absolute(value);

		final lower = value.m % scale.m;
		final upper = scale.m - lower;
		final isHalf = (lower - Dec64.of(5, -1)).isInteger();

		inline function up() return new Money(value.m + upper, value.region);
		inline function down() return new Money(value.m - lower, value.region);
		inline function away() return if(lower.compare(upper) == IsLess) down() else up();
		inline function ceil() return if(sign < 0) down() else up();
		inline function floor() return if(sign < 0) up() else down();

		return if(options.down) down();
		else if(options.floor) floor();
		else if(options.ceiling) ceil();
		else if(options.even) (if(isHalf && even_q(value).cond) down() else away())
		else if(options.halfDown) (if(isHalf) down() else away())
		else if(options.halfCeiling) (if(isHalf) ceil() else away())
		else away();
	}

	override function even_q(value: Money) {
		return Logic.fromCond(!odd_q(value).cond);
	}

	override function odd_q(value: Money) {
		// lazy for now lol
		return Logic.fromCond(value.m.toDouble() % 1 == 0);
	}


	/*-- Series actions --*/

	override function pick(value: Money, index: Value): Value {
		final idx = index._match(
			at(i is Integer) => i.int,
			at(w is Word) => getNamedIndex(w, value),
			_ => invalid()
		);
		return idx._match(
			at(1) => new Money(value.m, null),
			at(2) => value.region ?? cast None.NONE,
			_ => throw "out of range"
		);
	}
}