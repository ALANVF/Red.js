package util;

#if js
import js.lib.Math as JsMath;
#end

// Directly translated from https://github.com/ALANVF/star/blob/master/vm/dec64.nim

@:build(util.Overload.build())
@:publicFields
abstract Dec64(BigInt) {
	// well js bigint doesn't overflow so we get to pretend it can
	private static final MAX64 = bigInt(9223372036854775807);

	static final ZERO = new Dec64(bigInt(0x000));
	static final ONE = new Dec64(bigInt(0x100));
	static final TWO = new Dec64(bigInt(0x200));
	static final NEG_ONE = new Dec64(bigInt("0xFFFFFFFFFFFFFF00"));
	static final NAN = new Dec64(bigInt("0x8000000000000080"));
	static final E = new Dec64(bigInt("0x6092A113D8D574F0"));
	static final HALF = new Dec64(bigInt(0x5FF));
	static final HALF_PI = new Dec64(bigInt("0x37CE4F32BB21A6F0"));
	static final NHALF_PI = new Dec64(bigInt("0xC831B0CD44DE59F0"));
	static final NPI = new Dec64(bigInt("0x9063619A89BCB4F0"));
	static final PI = new Dec64(bigInt("0x6F9C9E6576434CF0"));
	static final TWO_PI = new Dec64(bigInt("0x165286144ADA42F1"));
	static final POWER = BigInt64Array.of(
		bigInt(1),
		bigInt(10),
		bigInt(100),
		bigInt(1000),
		bigInt(10000),
		bigInt(100000),
		bigInt(1000000),
		bigInt(10000000),
		bigInt(100000000),
		bigInt(1000000000),
		bigInt(10000000000),
		bigInt(100000000000),
		bigInt(1000000000000),
		bigInt(10000000000000),
		bigInt(100000000000000),
		bigInt(1000000000000000),
		bigInt(10000000000000000),
		bigInt(100000000000000000),
		bigInt(1000000000000000000),
		bigInt(10000000000000000000),
		bigInt(0)
	);

	static overload function toUnsigned(i: BigInt) {
		return i < 0 ? bigInt(256) + i : i;
	}
	static overload function toUnsigned(i: Int) {
		return i < 0 ? 256 + i : i;
	}

	static overload function toSigned(i: BigInt) {
		return i > bigInt(127) ? i - bigInt(256) : i;
	}
	static overload function toSigned(i: Int) {
		return i > 127 ? i - 256 : i;
	}

	var coefficient(get, never): BigInt; private inline function get_coefficient() {
		return this >> bigInt(8);
	}
	var exponent(get, never): BigInt; private inline function get_exponent() {
		return toSigned(this & bigInt(255));
	}

	private inline function new(b: BigInt) this = b;

	static overload function of(coef: Int, exp: Int) {
		return new Dec64((new BigInt(coef) << bigInt(8)) | new BigInt(toUnsigned(exp)));
	}
	static overload function of(coef: BigInt, exp: Int) {
		return new Dec64((coef << bigInt(8)) | new BigInt(toUnsigned(exp)));
	}
	static overload function of(coef: BigInt, exp: BigInt) {
		return new Dec64((coef << bigInt(8)) | toUnsigned(exp));
	}

	private inline function asBigInt() return this;

	static function make(coef: BigInt, exp: Int) {
		var x = coef;
		var e = exp;
		
		if(x == 0 || e <= -148) return ZERO;

		while(e < 127) {
			//trace("@"+e);
			final signmask = x >> bigInt(63); // signmask is -1 if x is negative, or 0 if positive
			final xAbs = /*uint64*/ x ^ signmask;
			if(xAbs >= bigInt(3602879701896396800)) {
				//trace(1);
				// pack large ...
				x = (x ^ signmask) - signmask;
				x = ((x * bigInt(-3689348814741910323)) >> bigInt(64)) >> bigInt(3);
				x = (x ^ signmask) - signmask;
				e++;
			} else {
				//trace(2);
				var deficit = (xAbs > bigInt(36028797018963967)).asInt() + (xAbs > bigInt(360287970189639679)).asInt();
				deficit = JsMath.max(-127 - e, deficit);
				if(deficit == 0) {
					/* this is the "hot path":
					 *   1. enter makeDec64
					 *   2. enter while loop since e <= 127 most of the time
					 *   3. pass quite liberal mantissa "smallness" check
					 *   4. pass few more checks to ensure that deficit == 0
					 *   5. and here we are, just pack the result and go.
					 * that is, while makeDec64() looks heavy, most of the time
					 * it finishes fast without a single multiplication or division,
					 * just a few well predictable branches,
					 * simple arithmetic and bit operations.
					 */
					if(x != 0) {
						return of(x, e);
					} else {
						return ZERO;
					}
				}
				
				// pack increase
				if(deficit >= 20) return ZERO; // underflow
				final scale = POWER[deficit];
				if(x > 0) {
					x = (x + (scale >> bigInt(1))) / scale;
				} else {
					x = (x - (scale >> bigInt(1))) / scale;
				}
				e += deficit;
			}
		}
		trace(x, e);

		if(e >= 148) return NAN;

		// If the exponent is too big (greater than 127).
		// We can attempt to reduce it by scaling back.
		// This can salvage values in a small set of cases.
		final xAbs = x.abs();
		final lsb =
			if(xAbs == 0) 63
			else Math.clz64(x) - 1;
		var log10Scale =
			if(lsb > 0) (lsb * 77) >> 8
			else 0;
		log10Scale = JsMath.min(e - 127, log10Scale);
		x *= POWER[log10Scale]; // in theory, this shouldn't overflow
		e -= log10Scale;

		while(e > 127) {
			// try multiplying the coefficient by 10
			// if it overflows, we failed to salvage
			x *= bigInt(10);
			if(x > MAX64) {
				return NAN;
			}

			e--;
		}

		// check for overflow
		if(x <= MAX64) {
			return of(x, e);
		} else {
			return ZERO;
		}
	}

	static function fromDouble(d: Float) {
		return fromString(d.toString());
		// too many rounding issues
		/*final SHIFT = 18;
		Util.detuple(@var [m, e2], Math.frexp(d));
		final e10 = e2 * 0.3010299956639811952137388947;
		final e = Std.int(Math.ceil(e10));
		m *= Math.pow(10, e10 - e);
		final m64 = new BigInt(Math.round(m * 1000000000000000000));
		// still has some rounding issues
		return make(m64, e - SHIFT)
			.round(of(new BigInt((e - 15) * 256), 0))
			.normal();*/
	}

	static function fromString(str: String) {
		if(str == "") return NAN;

		var c = str.cca(0);
		var at;
		var sign;
		var coefficient = 0;
		var digits = 0;
		var exponent = 0;
		var leading = true;
		var ok = true;
		var point = 0;

		if(c == '-'.code) {
			c = str.cca(1);
			at = 1;
			sign = -1;
		} else {
			at = 0;
			sign = 1;
		}

		while(at < str.length) {
			if(c != "'".code) {
				if(c == '0'.code) {
					ok = true;
					if(leading) {
						exponent -= point;
					} else {
						digits++;
						if(digits > 18) {
							exponent += 1 - point;
						} else {
							coefficient *= 10;
							exponent -= point;
						}
					}
				} else if(c >= '1'.code && c <= '9'.code) {
					ok = true;
					leading = false;
					
					digits++;
					if(digits > 18) {
						exponent += 1 - point;
					} else {
						coefficient = coefficient * 10 + (c - '0'.code);
						exponent -= point;
					}
				} else if(c == '.'.code || c == ','.code) {
					if(point == 1) return NAN;
					point = 1;
				} else {
					if(c == 'e'.code || c == 'E'.code) {
						if(ok) {
							ok = false;
							var exp = 0;
							var expSign = 0;
							c = str.cca(++at);

							if(c == '-'.code) {
								expSign = -1;
								c = str.cca(++at);
							} else {
								c = str.cca(++at);
							}

							while(at < str.length) {
								if(c >= '0'.code && c <= '9'.code) {
									ok = true;
									exp = exp * 10 + (c - '0'.code);
									if(exp < 0) return NAN;
								} else {
									return NAN;
								}
							}
							c = str.cca(++at);

							if(ok) {
								return make(
									new BigInt(sign * coefficient),
									(expSign * exp) + exponent
								);
							}
						}

						return NAN;
					}
				}
			}

			c = str.cca(++at);
		}
		
		return ok ? make(new BigInt(sign * coefficient), exponent) : NAN;
	}

	function toDouble() {
		// lazy lol
		return Std.parseFloat(normal().toString());
	}

	function toString() {
		if(coefficient == 0) return "0";
		var d = normal();
		var dCoef = d.coefficient;
		var dExp = d.exponent;

		var result = dCoef.abs().toString();
		//trace(dExp);
		if(dExp > 0) {
			result += "0".repeat(dExp.toInt());
		} else if(dExp < 0) {
			if(dExp == -128) return "NaN";
			if(dExp.abs() == result.length) result = "0" + result;
			else if(dExp.abs() > result.length) {
				result = "0" + result;
				result = "0".repeat(1 + Math.iabs(dExp.toInt()) - result.length) + result;
			}
			final i = result.length + dExp.toInt();
			result = result._substr(0, i) + "." + result._substr(i);
		}

		if(dCoef < 0) result = "-" + result;

		return result;
	}

	function toExponential() {
		return '${coefficient}e${exponent}';
	}

	function toFixed(digits: Int) {
		var d = normal();
		var dCoef = d.coefficient;
		var dExp = d.exponent;

		var result = dCoef.abs().toString();
		//trace(dExp);
		if(dExp > 0) {
			result += "0".repeat(dExp.toInt());
		} else if(dExp < 0) {
			if(dExp == -128) return "NaN";
			if(dExp.abs() == result.length) result = "0" + result;
			else if(dExp.abs() > result.length) {
				result = "0" + result;
				result = "0".repeat(1 + Math.iabs(dExp.toInt()) - result.length) + result;
			}
			final i = result.length + dExp.toInt();
			var end = result._substr(i, digits);
			if(end.length < digits) end += "0".repeat(digits - end.length);
			result = result._substr(0, i) + "." + end;
		} else {
			result += "." + "0".repeat(digits);
		}

		if(dCoef < 0) result = "-" + result;

		return result;
	}

	@:op(A == B)
	function eq(other: Dec64) {
		final xExp = exponent;
		final yExp = other.exponent;
		
		final xi = this;
		final yi = other.asBigInt();

		var ediff = xExp - yExp;
		if(ediff == 0) return xExp == -128 || xi == yi;

		if(xi ^ yi <= 0) return false;

		// Let's do exact comparison instead of relying on dec64.`-`() rounding logic.
		// This is also faster, because we do not need to pack the final result, and
		// we don't have to fix possible overflow; instead we use the fact of
		// overflow to claim inequality

		// If user wants to check whether x ~ y,
		// they can use the slower dec64.is_zero(dec64.`-`(x, y))

		// Before comparison can take place, the exponents must be made to match.
		// Swap the numbers if the second exponent is greater than the first.
		var x1, y1;
		if(ediff < 0) { x1 = yi; y1 = xi; }
		else { x1 = xi; y1 = yi; }
		ediff = ediff.abs();

		// if one of the arguments is nan or the difference between
		// exponents is very big, they are not equal
		if(ediff > 17 || xExp == -128 || yExp == -128) return false;

		// try to bring e0 -> e1 by scaling up x.
		// before scaling x's exponent bits are cleared not to
		// affect the coefficient bits.
		// If we get overflow, it means that x cannot be represented
		// with the same exponent as y, which means that x != y
		final xScaled = {
			final res = (x1 & ~bigInt(255)) * POWER[ediff.toInt()];
			if(res > MAX64) return false;
			res;
		};
	
		return xScaled == (y1 & ~bigInt(255));
	}


	@:op(A != B)
	function ne(other: Dec64) return !(abstract == other);

	/*function epsEqual(other: Dec64, eps: Dec64) {
		if(abstract == other) {
			return true;
		} else {
			return (abstract - other).abs() < eps;
		}
	}*/

	function isInteger() {
		// If the number contains a non-zero fractional part or if it is nan,
		// return false. Otherwise, return true.
		final x = coefficient;
		final e = exponent;

		// a positive exponent means an integer,
		// zero is an integer and
		// nan is not an integer
		if(e >= 0 || (x == 0 && e != -128)) return true;
		// huge negative exponents can never be int,
		// this check handles nan too.
		if(e < -17) return false;
		return x % POWER[-e.toInt()] == 0;
	}

	@:op(A < B)
	function lt(other: Dec64) {
		// Compare two dec64 numbers. If the first is less than the second, return true,
		// otherwise return false. Any nan value is greater than any number value

		// If the exponents are the same, then do a simple compare.
		final ex = exponent;
		final ey = other.exponent;
		if(ex == ey) {
			return ex != -128 && coefficient < other.coefficient;
		}

		// The exponents are not the same
		if(ex == -128) return false;
		if(ey == -128) return true;

		var ediff = ex - ey;
		final cx = coefficient;
		final cy = other.coefficient;
		if(ediff > 0) {
			// The maximum cofficient is 36028797018963967. 10**18 is more than that.
			ediff = ediff.min(bigInt(18));
			// We need to make them conform before we can compare. Multiply the first
			// coefficient by 10**(first exponent - second exponent)
			final xScaled = this * POWER[ediff.toInt()];
			final xHigh = xScaled >> bigInt(64);
			final x2 = xScaled;

			// in the case of overflow check the sign of higher 64-bit half;
			// otherwise compare numbers with equalized exponents
			if(xHigh == x2 >> bigInt(63)) {
				return x2 < cy;
			} else {
				return xHigh < 0;
			}
		} else {
			// The maximum cofficient is 36028797018963967. 10**18 is more than that.
			ediff = (-ediff).max(bigInt(18));
			final yScaled = other.asBigInt() * POWER[ediff.toInt()];
			final yHigh = yScaled >> bigInt(64);
			final y2 = yScaled;

			// in the case of overflow check the sign of higher 64-bit half;
			// otherwise compare numbers with equalized exponents
			if(yHigh == y2 >> bigInt(63)) {
				return cx < y2;
			} else {
				return yHigh >= 0;
			}
		}
	}

	@:op(A <= B) inline function le(other: Dec64) return !(other < abstract);
	@:op(A > B) inline function gt(other: Dec64) return other < abstract;
	@:op(A >= B) inline function ge(other: Dec64) return !(abstract < other);

	inline function compare(other: Dec64) return (abstract - other).sign();
	
	function isNaN() return exponent == -128;
	
	function isZero() {
		if(exponent == -128) return false;
		return coefficient == 0;
	}
	
	static function addSlow(cx: BigInt, ex: Int, cy: BigInt, ey: Int) {
		// The slower path is taken when the exponents are different.
		// Before addition can take place, the exponents must be made to match.
		// Swap the numbers if the second exponent is greater than the first.
		var r0: BigInt = js.Syntax.code("{0}", cy);
		var r1: BigInt = js.Syntax.code("{0}", cx);
		var e0: Int = js.Syntax.code("{0}", ey);
		var e1: Int = js.Syntax.code("{0}", ex);
		if(ex > ey) {
			Util.swap(r0, r1);
			Util.swap(e0, e1);
		}
		final r0_0 = r0;
		final e0_0 = e0;

		// it's enough to check only e1 or -128;
		// if e1 is not 128, e0 cannot be -128, since it's greater
		if(e1 == -128) return NAN;
		if(r0 == 0) e0 = e1;
		
		if(e0 > e1) {
			final r0Abs = r0.abs();
			final lsb =
				if(r0Abs == 0) 63
				else Math.clz64(r0Abs) - 1;
			var log10Scale =
				if(lsb > 0) (lsb * 77) >> 8
				else 0;
			log10Scale = JsMath.min(e0 - e1, log10Scale);
			r0 *= POWER[log10Scale];
			e0 -= log10Scale;

			while(e0 > e1) {
				// First, try to decrease the first exponent using "lossless" multiplication
				// of the first coefficient by multiplying it by 10 at a time.
				r0 *= bigInt(10);
				if(r0 > MAX64) {
					// We cannot decrease the first exponent any more, so we must instead try to
					// increase the second exponent, which will result in a loss of significance.
					// That is the heartbreak of floating point.

					// Determine how many places need to be shifted. If it is more than 17, there is
					// nothing more to add.
					final ediff = e0 - e1;
					if(ediff > 10) return make(r0_0, e0_0);
					r1 /= POWER[ediff];
					if(r1 == 0) return make(r0_0, e0_0);
					return make(r0 + r1, e0);
				}

				e0--;
			}
		}

		return make(r0 + r1, e0);
	}

	@:op(A + B)
	function add(other: Dec64) {
		// Add two dec64 numbers together.
		// If the two exponents are both zero (which is usually the case for integers)
		// we can take the fast path. Since the exponents are both zero, we can simply
		// add the numbers together and check for overflow.
		final xExp = exponent;
		final yExp = other.exponent;
		if(xExp | yExp == 0) {
			final res = coefficient + other.coefficient;
			if(res < MAX64) {
				return of(res, 0);
			} else {
				// If there was an overflow (extremely unlikely) then we must make it fit.
				// pack knows how to do that.
				return make(coefficient + other.coefficient, 0);
			}
		} else if(xExp ^ yExp == 0) {
			if(xExp == -128) return NAN;

			// The exponents match so we may add now. Zero out one of the exponents so there
			// will be no carry into the coefficients when the coefficients are added.
			// If the result is zero, then return the normal zero.
			final xCoef = coefficient;
			final yCoef = other.coefficient;
			final r = xCoef + yCoef;
			if(r < MAX64) {
				if(r == 0) {
					return ZERO;
				} else {
					return make(r, xExp.toInt()) .normal();
				}
			} else {
				return make(xCoef + yCoef, xExp.toInt()) .normal();
			}
		} else {
			return addSlow(coefficient, xExp.toInt(), other.coefficient, yExp.toInt()) .normal();
		}
	}

	@:op(A - B)
	function sub(other: Dec64) {
		// Add two dec64 numbers together.
		// If the two exponents are both zero (which is usually the case for integers)
		// we can take the fast path. Since the exponents are both zero, we can simply
		// add the numbers together and check for overflow.
		
		final xExp = exponent;
		final yExp = other.exponent;
		if(xExp | yExp == 0) {
			final res = this - other.asBigInt();
			if(res < MAX64) {
				return new Dec64(res);
			} else {
				// If there was an overflow (extremely unlikely) then we must make it fit.
				// pack knows how to do that.
				return make(coefficient - other.coefficient, 0);
			}
		} else if(xExp ^ yExp == 0) {
			if(xExp == -128) return NAN;

			// The exponents match so we may add now. Zero out one of the exponents so there
			// will be no carry into the coefficients when the coefficients are added.
			// If the result is zero, then return the normal zero.
			final xCoef = coefficient;
			final yCoef = other.coefficient;
			final r = xCoef - yCoef;
			if(r < MAX64) {
				if(r == 0) {
					return ZERO;
				} else {
					return of(r, xExp) .normal();
				}
			} else {
				return make(xCoef - yCoef, xExp.toInt()) .normal();
			}
		} else {
			return addSlow(coefficient, xExp.toInt(), -other.coefficient, yExp.toInt()) .normal();
		}
	}

	@:op(A * B)
	function mul(other: Dec64) {
		// Multiply two dec64 numbers together
		final ex = exponent.toInt();
		final ey = other.exponent.toInt();

		final cx = coefficient;
		final cy = other.coefficient;

		// The result is nan if one or both of the operands is nan and neither of the
		// operands is zero.

		if((cx == 0 && ex != -128) || (cy == 0 && ey != -128)) return ZERO;
		if(ex == -128 && ey == -128) return NAN;

		final rBig = cx * cy;
		final rHigh = rBig >> bigInt(64);
		final r = rBig;
		final e = ex + ey;
		if(rHigh == r >> bigInt(63)) { // no overflow
			return make(r, e) .normal();
		}

		final rHighAbs = rHigh.abs();
		final deltaEr = // TODO: figure out why this is sometimes -1
			if(rHighAbs == 0) 1
			else ((63 - Math.clz64(rHighAbs)) * 77) >> 8;
		
		// divide by the power of ten & pack the final result
		final r2 = rBig / POWER[deltaEr];
		return make(r2, e + deltaEr) .normal();
	}

	private static final FAST_TAB1 = UInt8ClampedArray.of(
		1, 5, 0, 25, 2, 0, 0, 125, 0, 1,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 5,
		0, 0, 0, 0, 4, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 25,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 2
	);
	private static final FAST_TAB2 = UInt8ClampedArray.of(
		0, 1, 0, 2, 1, 0, 0, 3, 0, 1,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 2,
		0, 0, 0, 0, 2, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 2
	);
	function divide(other: Dec64): Tuple3<Int, BigInt, Int> {
		// (x: Dec64, y: Dec64) returns quotient: Dec64
		// Divide a dec64 number by another.
		// Begin unpacking the components.
		var ex = exponent.toInt();
		var ey = other.exponent.toInt();
		var cx = coefficient;
		var cy = other.coefficient;
		if(cx == 0 && ex != -128) return new Tuple3(0, bigInt(0), 0);
		if(ex == -128 || ey == -128 || cy == 0) return new Tuple3(-1, bigInt(0), -128);

		// if both x and y are even then we can simplify the ratio lossless
		final b = new BigInt(JsMath.min(Math.ctz64(cx), Math.ctz64(cy)));
		cx >>= b;
		cy >>= b;
		
		final yAbs = cy.abs();
		final yAbsInt = yAbs.toInt();
		var scale = 0;
		if(yAbs <= 50) {
			scale = FAST_TAB1[yAbsInt - 1];
			if(scale != 0) {
				// fast division by some popular small constants
				// x/2 ~ (x*5)/10, x/5 ~ (x*2)/10, ...
				// and division by a power of 10 is just shift of the exponent
				return new Tuple3(
					1,
					cx * new BigInt(cy < 0 ? -scale : scale),
					ex - ey - FAST_TAB2[yAbsInt - 1]
				);
			}
		}

		// We want to get as many bits into the quotient as possible in order to capture
		// enough significance. But if the quotient has more than 64 bits, then there
		// will be a hardware fault. To avoid that, we compare the magnitudes of the
		// dividend coefficient and divisor coefficient, and use that to scale the
		// dividend to give us a good quotient.
		final yLog2 = 63 - Math.clz64(yAbs);
		var prescaleLog10 = 0;

		while(true) {
			final xAbs = cx.abs();
			final xLog2 = 63 - Math.clz64(xAbs);
		//trace(Math.clz64(xAbs), xLog2, cx, ex);
			// Scale up the dividend to be approximately 58 bits longer than the divisor.
			// Scaling uses factors of 10, so we must convert from a bit count to a digit
			// count by multiplication by 77/256 (approximately LN2/LN10).
			prescaleLog10 = ((yLog2 + 58 - xLog2) * 77) >> 8;
		//trace(prescaleLog10);
			if(prescaleLog10 <= 18) break;

			// If the number of scaling digits is larger than 18, then we will have to
			// scale in two steps: first prescaling the dividend to fill a register, and
			// then repeating to fill a second register. This happens when the divisor
			// coefficient is much larger than the dividend coefficient.

			// we want 58 bits or so in the dividend
			prescaleLog10 = ((58 - xLog2) * 77) >> 8;
			cx *= POWER[prescaleLog10];
			ex -= prescaleLog10;
		}

		// Multiply the dividend by the scale factor, and divide that 128 bit result by
		// the divisor. Because of the scaling, the quotient is guaranteed to use most
		// of the 64 bits in r0, and never more. Reduce the final exponent by the number
		// of digits scaled.
		return new Tuple3(
			1,
			cx * POWER[prescaleLog10] / cy,
			ex - ey - prescaleLog10
		);
	}

	@:op(A / B)
	function div(other: Dec64) {
		Util.detuple(@var [status, q, qexp], abstract.divide(other));
		return
			if(status == 0) ZERO
			else if(status == -1) NAN
			else make(q, qexp) .normal();
	}

	function fda(y: Dec64, z: Dec64) {
		final ez = z.exponent.toInt();
		if(ez == -128) return NAN;

		Util.detuple(@var [status, q, eq], abstract.divide(y));
		if(status == 0) return z;
		if(status == -1) return NAN;
		return addSlow(q, eq, z.coefficient, ez);
	}

	private function toInt(roundDir: Int) {
		// Produce the largest integer that is less than or equal to 'x' (round_dir == -1)
		// or greater than or equal to 'x' (round_dir == 1).
		// In the result, the exponent will be greater than or equal to zero unless it is nan.
		// Numbers with positive exponents will not be modified,
		// even if the numbers are outside of the safe integer range.

		var e = exponent.toInt();
		var c = coefficient;
		if(e == -128) return NAN;

		e = -e;
		var rem;
		if(e < 17) {
			final p = POWER[e];
			final cScaled = c / p;
			rem = c - (cScaled * p);
			if(rem == 0) {
				return new Dec64(cScaled << bigInt(8));
			}
			c = cScaled;
		} else {
			// deal with a micro number
			rem = c;
			c = bigInt(0);
		}
		final delta = ((rem ^ new BigInt(roundDir)) >= 0).asInt() * roundDir;
		return new Dec64((c + new BigInt(delta)) << bigInt(8));
	}

	inline function floor() return toInt(-1);
	inline function ceil() return toInt(1);
	inline function trunc() return toInt(0);

	function intDiv(other: Dec64) {
		final ex = exponent;
		final ey = other.exponent;
		if(ex == ey) {
			final cx = coefficient;
			final cy = other.coefficient;
			if(cx == 0 && ex != -128) return ZERO; // 0/y ~ 0, even if y == 0 or y == nan
			if(ex == -128 || ey == -128 || cy == 0) return NAN;
			// augment numerator to mimic floor(x/y), i.e. rounding towards minus infinity
			final delta =
				if(cx ^ cy >= 0) bigInt(0)
				else if(cy > 0) bigInt(1)
				else bigInt(-1);
			return new Dec64(((cx + delta) / cy) << bigInt(8));
		} else {
			return (abstract / other).floor();
		}
	}

	@:op(A % B)
	function mod(other: Dec64) {
		final ex = exponent;
		final ey = other.exponent;
		if(ex == ey) {
			final cx = coefficient;
			final cy = other.coefficient;
			if(cx == 0 && ex != -128) return ZERO; // 0 % y ~ 0, even if y == 0 or y == nan
			if(ex == -128 || ey == -128 || cy == 0) return NAN;
			final rem = cx % cy;
			// augment result to mimic x mod y == x - floor(x/y)*y
			return of(
				if(rem == 0) rem
				else rem + (
					if(cx ^ cy < 0) cy
					else bigInt(0)
				),
				ex
			);
		} else {
			return abstract - (abstract.intDiv(other) * other);
		}
	}

	// x*y + z
	function fma(y: Dec64, z: Dec64) {
		// Multiply two dec64 numbers together, then add another number;
		// Try to do it with higher precision than 2 separate operations
		final ex = exponent.toInt();
		final ey = y.exponent.toInt();
		final ez = z.exponent.toInt();

		final cx = coefficient;
		final cy = y.coefficient;

		// The result is nan if one or both of the operands is nan and neither of the
		// operands is zero.
		if((cx == 0 && ex != -128) || (cy == 0 && ey != -128)) return z;
		if(ex == -128 || ey == -128 || ez == -128) return NAN;

		final cz = z.coefficient;

		final rBig = cx * cy;
		final rHigh = rBig >> bigInt(64);
		final r = rBig;
		final e = ex + ey;
		// this is the difference from dec64_multiply
		// we need one extra bit for add_slow.
		if(rHigh == r >> bigInt(62)) {
			return addSlow(r, e, cz, ez);
		}

		final rHighAbs = rHigh.abs();
		final deltaEr =
			if(rHighAbs == 0) 1
			else (((63 - Math.clz64(rHighAbs)) * 77) >> 8) + 2;
		
		// divide by the power of 10 & add z;
		final r2 = rBig / POWER[deltaEr];
		return addSlow(r2, e + deltaEr, cz, ez);
	}

	@:op(-A)
	function neg() {
		final e = exponent.toInt();
		if(e == -128) return NAN;

		final r = -coefficient;
		return if(r != 0) of(r, e) else ZERO;
	}

	function abs() {
		if(exponent == -128) return NAN;
		final c = coefficient;
		return
			if(c < 0) neg()
			else if(c == 0) ZERO
			else abstract;
	}

	function sign() {
		return coefficient.toInt().sign();
	}

	function normal() {
		// Make the exponent as close to zero as possible without losing any signficance.
		// Usually normalization is not needed since it does not materially change the
		// value of a number.

		var e = exponent.toInt();
		if(e == -128) return NAN;
		if(e == 0) return abstract;

		var c = coefficient;
		if(c == 0) return ZERO;

		if(e < 0) {
			// While the exponent is less than zero, divide the coefficient by 10 and
			// increment the exponent.
			while(true) {
				final tmp = c / bigInt(10);
				if(c != tmp * bigInt(10)) break;
				c = tmp;
				e++;
				if(!(e < 0)) break;
			}
			return of(c, e);
		} else {
			// we keep the coefficient scaled by 256 to catch the overflow earlier,
			// inside 56 coefficient
			c <<= bigInt(8);

			// While the exponent is greater than zero, multiply the coefficient by 10 and
			// decrement the exponent. If the coefficient gets too large, wrap it up.
			while(true) {
				final prev = c;
				c *= bigInt(10);
				if(c < MAX64) {
					c = prev;
					break;
				}
				e--;
				if(!(e > 0)) break;
			}
			return new Dec64(c | new BigInt(e));
		}
	}

	function round(place: Dec64) {
		// The place argument indicates at what decimal place to round.
		//     -2        nearest cent
		//      0        nearest integer
		//      3        nearest thousand
		//      6        nearest million
		//      9        nearest billion

		// The place should be between -16 and 16;
		final ep = place.exponent;
		var cp = if(ep != 0) {
			if(ep == -128) bigInt(0) else {
				final p = place.normal();
				if(p.exponent != 0) return NAN;
				p.coefficient;
			}
		} else {
			place.coefficient;
		};

		var e = exponent.toInt();
		var c = coefficient;

		if(e == -128) return NAN;
		if(c == 0) return ZERO;

		// no rounding required
		if(e >= cp) return abstract;
		
		final isNeg = c < 0;
		var cAbs = c.abs();
		var cAbsScaled = bigInt(0);
		while(true) {
			cAbsScaled = (cAbs * bigInt(-3689348814741910323)) >> bigInt(64);
			cAbs = cAbsScaled >> bigInt(3);

			e++;
			if(!(e < cp)) break;
		}

		// Round if necessary and return the result.
		cAbs = (cAbsScaled >> bigInt(2)) & bigInt(1);
		// Restore the correct sign
		c = if(isNeg) -cAbs else cAbs;

		return make(c, e);
	}

	function signum() {
		// If the number is nan, the result is nan.
		// If the number is less than zero, the result is -1.
		// If the number is zero, the result is 0.
		// If the number is greater than zero, the result is 1.
		final e = exponent.toInt();
		if(e == -128) return NAN;

		final c = coefficient;
		return (
			if(c < 0) NEG_ONE
			else if(c == 0) ZERO
			else ONE
		);
	}

	function acos() {
		return HALF_PI - asin();
	}

	function asin() {
		if(abstract == ONE) return HALF_PI;
		if(abstract == NEG_ONE) return NHALF_PI;
		if(isNaN() || ONE < abs()) return NAN;

		var bottom = TWO;
		var factor = abstract;
		var x2 = abstract * abstract;
		var result = factor;
		while(true) {
			factor = (((NEG_ONE + bottom) * x2) * factor) / bottom;
			final progress = result + (factor / (ONE + bottom));
			if(result == progress) break;
			result = progress;
			bottom += TWO;
		}
		return factor;
	}

	function atan() {
		var d = abstract;
		var rev = false;
		var neg = false;
		if(coefficient < 0) {
			d = -d;
			neg = true;
		}
		if(ONE < d) {
			d = ONE / d;
			rev = true;
		}
		var a = (d / (ONE + (d * d)).sqrt()).asin();
		if(rev) a = HALF_PI - a;
		if(neg) a = -a;
		return a;
	}

	function atan2(other: Dec64) {
		return if(other.isZero()) {
			if(isZero()) NAN;
			else if(coefficient < 0) NHALF_PI;
			else HALF_PI;
		} else {
			final a = (abstract / other).atan();
			if(other.coefficient < 0) {
				if(coefficient < 0) a - HALF_PI;
				else a + HALF_PI;
			} else {
				a;
			}
		}
	}

	function sin() {
		var radians = abstract % TWO_PI;
		while(PI < radians) {
			radians -= PI;
			radians -= PI;
		}
		while(radians < NPI) {
			radians += PI;
			radians += PI;
		}
		var neg = false;
		if(coefficient < 0) {
			radians = -radians;
			neg = true;
		}
		if(HALF_PI < radians) {
			radians = PI - radians;
		}

		var result;
		if(radians < HALF_PI) {
			result = ONE;
		} else {
			final x2 = -(radians * radians);
			var term = radians;
			result = term;
			for(order in 1...30+1) {
				term *= x2;
				final o = new BigInt(order);
				term /= of((o*bigInt(2)) * (o*bigInt(2) + bigInt(1)), 0);
				final progress = result + term;
				if(progress == result) break;
				result = progress;
			}
		}

		if(neg) result = -result;
		return result;
	}

	function cos() {
		return (abstract + HALF_PI).sin();
	}

	function tan() {
		return sin() / cos();
	}

	private static inline final EXP_N = 256;
	private static final EXP_TAB = BigInt64Array.of(
		bigInt(2560000000000000240), bigInt(2537077391997084144), bigInt(2514360036321377008), bigInt(2491846095114035952),
		bigInt(2469533746972670192), bigInt(2447421186803987696), bigInt(2425506625677761264), bigInt(2403788290682102256),
		bigInt(2382264424780029680), bigInt(2360933286667324400), bigInt(2339793150631655920), bigInt(2318842306412969200),
		bigInt(2298079059065124592), bigInt(2277501728818772976), bigInt(2257108650945461744), bigInt(2236898175622956272),
		bigInt(2216868667801767664), bigInt(2197018507072874224), bigInt(2177346087536630512), bigInt(2157849817672847344),
		bigInt(2138528120212035312), bigInt(2119379432007803376), bigInt(2100402203910397936), bigInt(2081594900641374704),
		bigInt(2062956000669393648), bigInt(2044483996087124976), bigInt(2026177392489257456), bigInt(2008034708851600368),
		bigInt(1990054477411266288), bigInt(1972235243547927792), bigInt(1954575565666136816), bigInt(1937074015078697968),
		bigInt(1919729175891087088), bigInt(1902539644886902512), bigInt(1885504031414343920), bigInt(1868620957273707504),
		bigInt(1851889056605887728), bigInt(1835306975781876976), bigInt(1818873373293257712), bigInt(1802586919643670512),
		bigInt(1786446297241257968), bigInt(1770450200292069616), bigInt(1754597334694421488), bigInt(1738886417934201840),
		bigInt(1723316178981115632), bigInt(1707885358185854960), bigInt(1692592707178193136), bigInt(1677436988765989872),
		bigInt(1662416976835101168), bigInt(1647531456250185712), bigInt(1632779222756397808), bigInt(1618159082881963760),
		bigInt(1603669853841627376), bigInt(1589310363440961008), bigInt(1575079449981535472), bigInt(1560975962166935792),
		bigInt(1546998759009620208), bigInt(1533146709738614256), bigInt(1519418693708028656), bigInt(1505813600306398960),
		bigInt(1492330328866835184), bigInt(1478967788577976816), bigInt(1465724898395745264), bigInt(1452600586955886064),
		bigInt(1439593792487293936), bigInt(1426703462726115056), bigInt(1413928554830617584), bigInt(1401268035296823792),
		bigInt(1388720879874899696), bigInt(1376286073486291440), bigInt(1363962610141604336), bigInt(1351749492859217392),
		bigInt(1339645733584626672), bigInt(1327650353110509552), bigInt(1315762380997507568), bigInt(1303980855495714800),
		bigInt(1292304823466872816), bigInt(1280733340307259888), bigInt(1269265469871272176), bigInt(1257900284395687664),
		bigInt(1246636864424609776), bigInt(1235474298735082480), bigInt(1224411684263370736), bigInt(1213448126031902192),
		bigInt(1202582737076862192), bigInt(1191814638376437488), bigInt(1181142958779703024), bigInt(1170566834936143856),
		bigInt(1160085411225809648), bigInt(1149697839690094320), bigInt(1139403279963135216), bigInt(1129200899203825904),
		bigInt(1119089872028439280), bigInt(1109069380443852784), bigInt(1099138613781371632), bigInt(1089296768631145456),
		bigInt(1079543048777170672), bigInt(1069876665132877040), bigInt(1060296835677287920), bigInt(1050802785391755504),
		bigInt(1041393746197260272), bigInt(1032068956892272880), bigInt(1022827663091171056), bigInt(1013669117163210992),
		bigInt(1004592578172041456), bigInt(995597311815761392), bigInt(986682590367515376), bigInt(977847692616618480),
		bigInt(969091903810209520), bigInt(960414515595427824), bigInt(951814825962105584), bigInt(943292139185975536),
		bigInt(934845765772384752), bigInt(926475022400515056), bigInt(9181792318681008367), bigInt(9099577230366433519),
		bigInt(9018098307771139823), bigInt(8937348959161452527), bigInt(8857322651827027183), bigInt(8778012911552347375),
		bigInt(8699413322092952303), bigInt(8621517524656357103), bigInt(8544319217387618799), bigInt(8467812154859509487),
		bigInt(8391990147567254255), bigInt(8316847061427793903), bigInt(8242376817283530479), bigInt(8168573390410516975),
		bigInt(8095430810031051247), bigInt(8022943158830632687), bigInt(7951104572479244783), bigInt(7879909239156926191),
		bigInt(7809351399083585519), bigInt(7739425344053031663), bigInt(7670125416971171567), bigInt(7601446011398345711),
		bigInt(7533381571095761647), bigInt(7465926589575987951), bigInt(7399075609657472495), bigInt(7332823223023052271),
		bigInt(7267164069782412527), bigInt(7202092838038467567), bigInt(7137604263457621487), bigInt(7073693128843878383),
		bigInt(7010354263716765167), bigInt(6947582543893034223), bigInt(6885372891072111087), bigInt(6823720272425254895),
		bigInt(6762619700188397039), bigInt(6702066231258624751), bigInt(6642054966794279663), bigInt(6582581051818636015),
		bigInt(6523639674827127279), bigInt(6465226067398090735), bigInt(6407335503806996207), bigInt(6349963300644131055),
		bigInt(6293104816435705583), bigInt(6236755451268354287), bigInt(6180910646416996847), bigInt(6125565883976032751),
		bigInt(6070716686493837807), bigInt(6016358616610532847), bigInt(5962487276698997743), bigInt(5909098308509096687),
		bigInt(5856187392815093231), bigInt(5803750249066218223), bigInt(5751782635040369647), bigInt(5700280346500912367),
		bigInt(5649239216856550127), bigInt(5598655116824243951), bigInt(5548523954095149039), bigInt(5498841673003542255),
		bigInt(5449604254198714095), bigInt(5400807714319799535), bigInt(5352448105673518831), bigInt(5304521515914805743),
		bigInt(5257024067730294255), bigInt(5209951918524638959), bigInt(5163301260109646319), bigInt(5117068318396186607),
		bigInt(5071249353088867567), bigInt(5025840657383438319), bigInt(4980838557666907631), bigInt(4936239413220341487),
		bigInt(4892039615924327919), bigInt(4848235589967074031), bigInt(4804823791555120111), bigInt(4761800708626642159),
		bigInt(4719162860567323119), bigInt(4676906797928766191), bigInt(4635029102149432303), bigInt(4593526385278073071),
		bigInt(4552395289699642607), bigInt(4511632487863663343), bigInt(4471234682015022575), bigInt(4431198603927181295),
		bigInt(4391521014637770223), bigInt(4352198704186555375), bigInt(4313228491355747567), bigInt(4274607223412639215),
		bigInt(4236331775854544623), bigInt(4198399052156024559), bigInt(4160805983518373359), bigInt(4123549528621349871),
		bigInt(4086626673377132271), bigInt(4050034430686473967), bigInt(4013769840197044463), bigInt(3977829968063933423),
		bigInt(3942211906712299759), bigInt(3906912774602145519), bigInt(3871929715995196143), bigInt(3837259900723867887),
		bigInt(3802900523962304495), bigInt(3768848805999463663), bigInt(3735101992014235375), bigInt(3701657351852573679),
		bigInt(3668512179806624751), bigInt(3635663794395831535), bigInt(3603109538149999343), bigInt(3570846777394303727),
		bigInt(3538872902036223215), bigInt(3507185325354380015), bigInt(3475781483789271279), bigInt(3444658836735874543),
		bigInt(3413814866338109679), bigInt(3383247077285142511), bigInt(3352952996609510127), bigInt(3322930173487055855),
		bigInt(3293176179038654959), bigInt(3263688606133715695), bigInt(3234465069195439599), bigInt(3205503204007825391),
		bigInt(3176800667524402415), bigInt(3148355137678674159), bigInt(3120164313196261871), bigInt(3092225913408728303),
		bigInt(3064537678069069039), bigInt(3037097367168856303), bigInt(3009902760757020143), bigInt(2982951658760251375),
		bigInt(2956241880805013231), bigInt(2929771266041147119), bigInt(2903537672967057903), bigInt(2877538979256462831),
		bigInt(2851773081586694383), bigInt(2826237895468538095), bigInt(2800931355077595887), bigInt(2775851413087158255),
		bigInt(2750996040502573039), bigInt(2726363226497098479), bigInt(2701950978249223919), bigInt(2677757320781449455),
		bigInt(2653780296800507119), bigInt(2630017966539014639), bigInt(2606468407598545647), bigInt(2583129714794105583),
		bigInt(2560000000000000239)
	);
	private static final LOG10 = of(bigInt(23025850929940457), -16);
	private static final MLOG10 = of(bigInt(-23025850929940457), -16);
	private static final M256_DIV_LOG10 = of(bigInt(11117938736723247), -14);
	private static final LOG10_DIV_256 = of(bigInt(8994473019507991), -18);
	function exp() {
		if(isNaN()) return NAN;

		final e10 = (abstract / LOG10).ceil().normal();
		final e = e10.exponent;
		if(e >= 200) return NAN;
		if(e <= -200) return ZERO;
		var y = e10.fma(MLOG10, abstract);
		final yTab = (y * M256_DIV_LOG10).floor().normal();
		var tabIdx = yTab.asBigInt().toInt().clamp(0, EXP_N);
		y = of(tabIdx, 0).fma(LOG10_DIV_256, y);

		final scale = new Dec64(EXP_TAB[tabIdx]);
		var p = scale;
		var s = scale;

		for(n in 1...30+1) {
			p *= y / new Dec64(new BigInt(n * 256));
			final progress = s + p;
			if(progress == s) break;
			s = progress;
		}

		if(s.isNaN()) return NAN;

		return make(s.coefficient, (s.exponent + e).toInt());
	}


	private static inline final LOG_TAB_A = -950;
	private static inline final LOG_TAB_B = 1000;
	private static final LOG_TAB = BigInt64Array.of(
		bigInt(-7669074620298216720),  bigInt(-7618379894419996688),  bigInt(-7568669594625816592),  bigInt(-7519906215500838672),  bigInt(-7472054354989728272),
		bigInt(-7425080559999144976),  bigInt(-7378953185912288528),  bigInt(-7333642268537822224),  bigInt(-7289119407195437072),  bigInt(-7245357657795628816),
		bigInt(-7202331434905692944),  bigInt(-7160016421910593808),  bigInt(-7118389488478836240),  bigInt(-7077428614631947024),  bigInt(-7037112820793510672),
		bigInt(-6997422103261439504),  bigInt(-6958337374606621200),  bigInt(-6919840408553397520),  bigInt(-6881913788943437584),  bigInt(-6844540862425286672),
		bigInt(-6807705694547911696),  bigInt(-6771393028968503056),  bigInt(-6735588249513168912),  bigInt(-6700277344854389264),  bigInt(-6665446875591596048),
		bigInt(-6631083943541315856),  bigInt(-6597176163061263120),  bigInt(-6563711634248839952),  bigInt(-6530678917868915728),  bigInt(-6498067011878695696),
		bigInt(-6465865329429133584),  bigInt(-6434063678232827408),  bigInt(-6402652241197782544),  bigInt(-6371621558234979856),  bigInt(-6340962509155387664),
		bigInt(-6310666297579060496),  bigInt(-6280724435785290768),  bigInt(-6251128730438536208),  bigInt(-6221871269130062096),  bigInt(-6192944407679992592),
		bigInt(-6164340758148792080),  bigInt(-6136053177511134480),  bigInt(-6108074756948727312),  bigInt(-6080398811721935376),  bigInt(-6053018871583060752),
		bigInt(-6025928671696886032),  bigInt(-5999122144036609808),  bigInt(-5972593409225610512),  bigInt(-5946336768797606416),  bigInt(-5920346697849720336),
		bigInt(-5894617838064756752),  bigInt(-5869144991080646416),  bigInt(-5843923112186536720),  bigInt(-5818947304326403088),  bigInt(-5794212812392356624),
		bigInt(-5769715017791010832),  bigInt(-5745449433267378704),  bigInt(-5721411697971790864),  bigInt(-5697597572756268304),  bigInt(-5674002935687662864),
		bigInt(-5650623777765685008),  bigInt(-5627456198834695184),  bigInt(-5604496403678828560),  bigInt(-5581740698290678800),  bigInt(-5559185486304362256),
		bigInt(-5536827265584350480),  bigInt(-5514662624961977104),  bigInt(-5492688241112014864),  bigInt(-5470900875562168848),  bigInt(-5449297371828755472),
		bigInt(-5427874652672232976),  bigInt(-5406629717466613520),  bigInt(-5385559639677133840),  bigInt(-5364661564440881936),  bigInt(-5343932706245376272),
		bigInt(-5323370346700379664),  bigInt(-5302971832398487056),  bigInt(-5282734572860277008),  bigInt(-5262656038560050704),  bigInt(-5242733759028389904),
		bigInt(-5222965321027979536),  bigInt(-5203348366799322640),  bigInt(-5183880592373161232),  bigInt(-5164559745946581008),  bigInt(-5145383626319937552),
		bigInt(-5126350081391891216),  bigInt(-5107457006709977360),  bigInt(-5088702344074270736),  bigInt(-5070084080191826704),  bigInt(-5051600245379699728),
		bigInt(-5033248912314451728),  bigInt(-5015028194826159888),  bigInt(-4996936246735043088),  bigInt(-4978971260728908048),  bigInt(-4961131467279708944),
		bigInt(-4943415133597600272),  bigInt(-4925820562620929296),  bigInt(-4908346092040705808),  bigInt(-4890990093358136080),  bigInt(-4873750970973895184),
		bigInt(-4856627161307855888),  bigInt(-4839617131948064272),  bigInt(-4822719380827803152),  bigInt(-4805932435429635856),  bigInt(-4789254852015379984),
		bigInt(-4772685214880999184),  bigInt(-4756222135635455760),  bigInt(-4739864252502602000),  bigInt(-4723610229645235472),  bigInt(-4707458756510477840),
		bigInt(-4691408547195673616),  bigInt(-4675458339834045456),  bigInt(-4659606895999367440),  bigInt(-4643853000128958992),  bigInt(-4628195458964322576),
		bigInt(-4612633101008784144),  bigInt(-4597164776001519888),  bigInt(-4581789354407377424),  bigInt(-4566505726921927696),  bigInt(-4551312803991202576),
		bigInt(-4536209515345600528),  bigInt(-4521194809547461392),  bigInt(-4506267653551830800),  bigInt(-4491427032279956496),  bigInt(-4476671948205076240),
		bigInt(-4462001420950074640),  bigInt(-4447414486896602128),  bigInt(-4432910198805267984),  bigInt(-4418487625446532624),  bigInt(-4404145851241937936),
		bigInt(-4389883975915332112),  bigInt(-4375701114153756688),  bigInt(-4361596395277674512),  bigInt(-4347568962920232976),  bigInt(-4333617974715267344),
		bigInt(-4319742601993758992),  bigInt(-4305942029488475408),  bigInt(-4292215455046528784),  bigInt(-4278562089349600528),  bigInt(-4264981155641586192),
		bigInt(-4251471889463426064),  bigInt(-4238033538394898192),  bigInt(-4224665361803149840),  bigInt(-4211366630597763600),  bigInt(-4198136626992150544),
		bigInt(-4184974644271078928),  bigInt(-4171879986564146448),  bigInt(-4158851968625019920),  bigInt(-4145889915616260368),  bigInt(-4132993162899570192),
		bigInt(-4120161055831296784),  bigInt(-4107392949563036688),  bigInt(-4094688208847186448),  bigInt(-4082046207847294992),  bigInt(-4069466329953076752),
		bigInt(-4056947967599945744),  bigInt(-4044490522092943120),  bigInt(-4032093403434925840),  bigInt(-4019756030158896656),  bigInt(-4007477829164354320),
		bigInt(-3995258235557550864),  bigInt(-3983096692495540496),  bigInt(-3970992651033918736),  bigInt(-3958945569978142224),  bigInt(-3946954915738330896),
		bigInt(-3935020162187453968),  bigInt(-3923140790522808080),  bigInt(-3911316289130694160),  bigInt(-3899546153454202640),  bigInt(-3887829885864028432),
		bigInt(-3876166995532225040),  bigInt(-3864556998308823312),  bigInt(-3852999416601235216),  bigInt(-3841493779256366608),  bigInt(-3830039621445368592),
		bigInt(-3818636484550955024),  bigInt(-3807283916057218832),  bigInt(-3795981469441879824),  bigInt(-3784728704070902288),  bigInt(-3773525185095417104),
		bigInt(-3762370483350890512),  bigInt(-3751264175258479120),  bigInt(-3740205842728517136),  bigInt(-3729195073066077200),  bigInt(-3718231458878554896),
		bigInt(-3707314597985223696),  bigInt(-3696444093328708880),  bigInt(-3685619552888334864),  bigInt(-3674840589595295504),  bigInt(-3664106821249603344),
		bigInt(-3653417870438772752),  bigInt(-3642773364458193936),  bigInt(-3632172935233153552),  bigInt(-3621616219242466576),  bigInt(-3611102857443673872),
		bigInt(-3600632495199769616),  bigInt(-3590204782207421712),  bigInt(-3579819372426649104),  bigInt(-3569475924011916304),  bigInt(-3559174099244619024),
		bigInt(-3548913564466919696),  bigInt(-3538693990016903952),  bigInt(-3528515050165026832),  bigInt(-3518376423051818768),  bigInt(-3508277790626817040),
		bigInt(-3498218838588699664),  bigInt(-3488199256326590736),  bigInt(-3478218736862508048),  bigInt(-3468276976794929936),  bigInt(-3458373676243453968),
		bigInt(-3448508538794519568),  bigInt(-3438681271448175376),  bigInt(-3428891584565862672),  bigInt(-3419139191819193360),  bigInt(-3409423810139701264),
		bigInt(-3399745159669541648),  bigInt(-3390102963713121040),  bigInt(-3380496948689631760),  bigInt(-3370926844086477584),  bigInt(-3361392382413562384),
		bigInt(-3351893299158431248),  bigInt(-3342429332742236432),  bigInt(-3333000224476517392),  bigInt(-3323605718520773648),  bigInt(-3314245561840810768),
		bigInt(-3304919504167848208),  bigInt(-3295627297958366736),  bigInt(-3286368698354684176),  bigInt(-3277143463146239760),  bigInt(-3267951352731574544),
		bigInt(-3258792130080991504),  bigInt(-3249665560699881488),  bigInt(-3240571412592699920),  bigInt(-3231509456227582224),  bigInt(-3222479464501583120),
		bigInt(-3213481212706525200),  bigInt(-3204514478495448080),  bigInt(-3195579041849640464),  bigInt(-3186674685046248976),  bigInt(-3177801192626444304),
		bigInt(-3168958351364140048),  bigInt(-3160145950235249680),  bigInt(-3151363780387469328),  bigInt(-3142611635110578192),  bigInt(-3133889309807245584),
		bigInt(-3125196601964331792),  bigInt(-3116533311124676112),  bigInt(-3107899238859359504),  bigInt(-3099294188740435216),  bigInt(-3090717966314113296),
		bigInt(-3082170379074395920),  bigInt(-3073651236437148688),  bigInt(-3065160349714604304),  bigInt(-3056697532090285584),  bigInt(-3048262598594343184),
		bigInt(-3039855366079296784),  bigInt(-3031475653196175888),  bigInt(-3023123280371045904),  bigInt(-3014798069781920016),  bigInt(-3006499845336042256),
		bigInt(-2998228432647539216),  bigInt(-2989983659015431184),  bigInt(-2981765353401995792),  bigInt(-2973573346411478288),  bigInt(-2965407470269142032),
		bigInt(-2957267558800650000),  bigInt(-2949153447411775504),  bigInt(-2941064973068432144),  bigInt(-2933001974277017872),  bigInt(-2924964291065068560),
		bigInt(-2916951764962213648),  bigInt(-2908964238981430032),  bigInt(-2901001557600585232),  bigInt(-2893063566744269840),  bigInt(-2885150113765907472),
		bigInt(-2877261047430142736),  bigInt(-2869396217895499024),  bigInt(-2861555476697302032),  bigInt(-2853738676730862608),  bigInt(-2845945672234918672),
		bigInt(-2838176318775324176),  bigInt(-2830430473228989712),  bigInt(-2822707993768059920),  bigInt(-2815008739844334352),  bigInt(-2807332572173917456),
		bigInt(-2799679352722100496),  bigInt(-2792048944688467728),  bigInt(-2784441212492224528),  bigInt(-2776856021757742608),  bigInt(-2769293239300317968),
		bigInt(-2761752733112140560),  bigInt(-2754234372348467728),  bigInt(-2746738027314001424),  bigInt(-2739263569449464336),  bigInt(-2731810871318370832),
		bigInt(-2724379806593989648),  bigInt(-2716970250046496528),  bigInt(-2709582077530311184),  bigInt(-2702215165971616272),  bigInt(-2694869393356057104),
		bigInt(-2687544638716614672),  bigInt(-2680240782121654032),  bigInt(-2672957704663142160),  bigInt(-2665695288445030928),  bigInt(-2658453416571808016),
		bigInt(-2651231973137206288),  bigInt(-2644030843213072656),  bigInt(-2636849912838394640),  bigInt(-2629689069008477712),  bigInt(-2622548199664276752),
		bigInt(-2615427193681872144),  bigInt(-2608325940862095376),  bigInt(-2601244331920296720),  bigInt(-2594182258476252688),  bigInt(-2587139613044214544),
		bigInt(-2580116289023092240),  bigInt(-2573112180686773008),  bigInt(-2566127183174570768),  bigInt(-2559161192481807376),  bigInt(-2552214105450521104),
		bigInt(-2545285819760299024),  bigInt(-2538376233919236624),  bigInt(-2531485247255015440),  bigInt(-2524612759906102800),  bigInt(-2517758672813068816),
		bigInt(-2510922887710018832),  bigInt(-2504105307116140560),  bigInt(-2497305834327363088),  bigInt(-2490524373408126224),  bigInt(-2483760829183259152),
		bigInt(-2477015107229966096),  bigInt(-2470287113869916176),  bigInt(-2463576756161438224),  bigInt(-2456883941891816976),  bigInt(-2450208579569689872),
		bigInt(-2443550578417542928),  bigInt(-2436909848364303632),  bigInt(-2430286300038029072),  bigInt(-2423679844758690576),  bigInt(-2417090394531048208),
		bigInt(-2410517862037618704),  bigInt(-2403962160631734288),  bigInt(-2397423204330686480),  bigInt(-2390900907808961808),  bigInt(-2384395186391559952),
		bigInt(-2377905956047398672),  bigInt(-2371433133382800400),  bigInt(-2364976635635063056),  bigInt(-2358536380666109968),  bigInt(-2352112286956220176),
		bigInt(-2345704273597836816),  bigInt(-2339312260289453584),  bigInt(-2332936167329576720),  bigInt(-2326575915610762256),  bigInt(-2320231426613726480),
		bigInt(-2313902622401530384),  bigInt(-2307589425613835024),  bigInt(-2301291759461227536),  bigInt(-2295009547719616784),  bigInt(-2288742714724698128),
		bigInt(-2282491185366485776),  bigInt(-2276254885083909904),  bigInt(-2270033739859483152),  bigInt(-2263827676214026768),  bigInt(-2257636621201465872),
		bigInt(-2251460502403683088),  bigInt(-2245299247925436688),  bigInt(-2239152786389338896),  bigInt(-2233021046930894352),  bigInt(-2226903959193597968),
		bigInt(-2220801453324090896),  bigInt(-2214713459967374096),  bigInt(-2208639910262080272),  bigInt(-2202580735835799056),  bigInt(-2196535868800458768),
		bigInt(-2190505241747763472),  bigInt(-2184488787744682256),  bigInt(-2178486440328991760),  bigInt(-2172498133504870928),  bigInt(-2166523801738547216),
		bigInt(-2160563379953993744),  bigInt(-2154616803528676368),  bigInt(-2148684008289348112),  bigInt(-2142764930507896592),  bigInt(-2136859506897234192),
		bigInt(-2130967674607239440),  bigInt(-2125089371220742672),  bigInt(-2119224534749559824),  bigInt(-2113373103630568464),  bigInt(-2107535016721831952),
		bigInt(-2101710213298765072),  bigInt(-2095898633050344976),  bigInt(-2090100216075363344),  bigInt(-2084314902878723344),  bigInt(-2078542634367775248),
		bigInt(-2072783351848695568),  bigInt(-2067036997022906640),  bigInt(-2061303511983534352),  bigInt(-2055582839211908624),  bigInt(-2049874921574099728),
		bigInt(-2044179702317495056),  bigInt(-2038497125067414032),  bigInt(-2032827133823758864),  bigInt(-2027169672957703440),  bigInt(-2021524687208419856),
		bigInt(-2015892121679837456),  bigInt(-2010271921837442320),  bigInt(-2004664033505106704),  bigInt(-1999068402861957136),  bigInt(-1993484976439275024),
		bigInt(-1987913701117430544),  bigInt(-1982354524122850320),  bigInt(-1976807393025019152),  bigInt(-1971272255733511440),  bigInt(-1965749060495057168),
		bigInt(-1960237755890638352),  bigInt(-1954738290832617232),  bigInt(-1949250614561893392),  bigInt(-1943774676645094928),  bigInt(-1938310426971795472),
		bigInt(-1932857815751763728),  bigInt(-1927416793512241168),  bigInt(-1921987311095248912),  bigInt(-1916569319654922256),  bigInt(-1911162770654874896),
		bigInt(-1905767615865589008),  bigInt(-1900383807361835280),  bigInt(-1895011297520117008),  bigInt(-1889650039016143376),  bigInt(-1884299984822327568),
		bigInt(-1878961088205312784),  bigInt(-1873633302723522064),  bigInt(-1868316582224733712),  bigInt(-1863010880843684624),  bigInt(-1857716152999693328),
		bigInt(-1852432353394313744),  bigInt(-1847159437009006608),  bigInt(-1841897359102840848),  bigInt(-1836646075210213904),  bigInt(-1831405541138598160),
		bigInt(-1826175712966309648),  bigInt(-1820956547040298000),  bigInt(-1815747999973961744),  bigInt(-1810550028644983824),  bigInt(-1805362590193188880),
		bigInt(-1800185642018423568),  bigInt(-1795019141778456336),  bigInt(-1789863047386901008),  bigInt(-1784717317011159056),  bigInt(-1779581909070382864),
		bigInt(-1774456782233459728),  bigInt(-1769341895417016848),  bigInt(-1764237207783443984),  bigInt(-1759142678738938128),  bigInt(-1754058267931566864),
		bigInt(-1748983935249349392),  bigInt(-1743919640818358800),  bigInt(-1738865345000841744),  bigInt(-1733821008393357072),  bigInt(-1728786591824932368),
		bigInt(-1723762056355239696),  bigInt(-1718747363272787216),  bigInt(-1713742474093130768),  bigInt(-1708747350557100560),  bigInt(-1703761954629047824),
		bigInt(-1698786248495106064),  bigInt(-1693820194561469968),  bigInt(-1688863755452691984),  bigInt(-1683916894009994000),  bigInt(-1678979573289595664),
		bigInt(-1674051756561059600),  bigInt(-1669133407305651216),  bigInt(-1664224489214715408),  bigInt(-1659324966188068112),  bigInt(-1654434802332402704),
		bigInt(-1649553961959713808),  bigInt(-1644682409585733392),  bigInt(-1639820109928382992),  bigInt(-1634967027906241296),  bigInt(-1630123128637024272),
		bigInt(-1625288377436081680),  bigInt(-1620462739814907152),  bigInt(-1615646181479661072),  bigInt(-1610838668329708560),  bigInt(-1606040166456171792),
		bigInt(-1601250642140493840),  bigInt(-1596470061853017616),  bigInt(-1591698392251577104),  bigInt(-1586935600180102416),  bigInt(-1582181652667237904),
		bigInt(-1577436516924971280),  bigInt(-1572700160347277840),  bigInt(-1567972550508776208),  bigInt(-1563253655163395856),  bigInt(-1558543442243057424),
		bigInt(-1553841879856365840),  bigInt(-1549148936287313680),  bigInt(-1544464579993998608),  bigInt(-1539788779607350800),  bigInt(-1535121503929872144),
		bigInt(-1530462721934387984),  bigInt(-1525812402762809616),  bigInt(-1521170515724906512),  bigInt(-1516537030297093648),  bigInt(-1511911916121223952),
		bigInt(-1507295143003398160),  bigInt(-1502686680912779792),  bigInt(-1498086499980423440),  bigInt(-1493494570498114576),  bigInt(-1488910862917216784),
		bigInt(-1484335347847531536),  bigInt(-1479767996056167952),  bigInt(-1475208778466421520),  bigInt(-1470657666156663312),  bigInt(-1466114630359239952),
		bigInt(-1461579642459381776),  bigInt(-1457052673994122256),  bigInt(-1452533696651225360),  bigInt(-1448022682268123152),  bigInt(-1443519602830863376),
		bigInt(-1439024430473065232),  bigInt(-1434537137474884368),  bigInt(-1430057696261988112),  bigInt(-1425586079404537360),  bigInt(-1421122259616180496),
		bigInt(-1416666209753053456),  bigInt(-1412217902812789008),  bigInt(-1407777311933535760),  bigInt(-1403344410392984336),  bigInt(-1398919171607402768),
		bigInt(-1394501569130680080),  bigInt(-1390091576653377808),  bigInt(-1385689168001789712),  bigInt(-1381294317137010192),  bigInt(-1376906998154009360),
		bigInt(-1372527185280718096),  bigInt(-1368154852877118224),  bigInt(-1363789975434343696),  bigInt(-1359432527573785616),  bigInt(-1355082484046208528),
		bigInt(-1350739819730871824),  bigInt(-1346404509634659344),  bigInt(-1342076528891216144),  bigInt(-1337755852760093456),  bigInt(-1333442456625899536),
		bigInt(-1329136315997458448),  bigInt(-1324837406506975248),  bigInt(-1320545703909209360),  bigInt(-1316261184080653328),  bigInt(-1311983823018720272),
		bigInt(-1307713596840935952),  bigInt(-1303450481784139280),  bigInt(-1299194454203688720),  bigInt(-1294945490572675856),  bigInt(-1290703567481144336),
		bigInt(-1286468661635316496),  bigInt(-1282240749856825616),  bigInt(-1278019809081955088),  bigInt(-1273805816360882960),  bigInt(-1269598748856934160),
		bigInt(-1265398583845836816),  bigInt(-1261205298714986512),  bigInt(-1257018870962715920),  bigInt(-1252839278197569552),  bigInt(-1248666498137585936),
		bigInt(-1244500508609584912),  bigInt(-1240341287548460048),  bigInt(-1236188812996477712),  bigInt(-1232043063102582288),  bigInt(-1227904016121704464),
		bigInt(-1223771650414079248),  bigInt(-1219645944444565008),  bigInt(-1215526876781971216),  bigInt(-1211414426098390544),  bigInt(-1207308571168535824),
		bigInt(-1203209290869082896),  bigInt(-1199116564178018320),  bigInt(-1195030370173993744),  bigInt(-1190950688035682064),  bigInt(-1186877497041142800),
		bigInt(-1182810776567190032),  bigInt(-1178750506088764944),  bigInt(-1174696665178315536),  bigInt(-1170649233505179664),  bigInt(-1166608190834972176),
		bigInt(-1162573517028979984),  bigInt(-1158545192043557904),  bigInt(-1154523195929532432),  bigInt(-1150507508831608592),  bigInt(-1146498110987781392),
		bigInt(-1142494982728753680),  bigInt(-1138498104477355280),  bigInt(-1134507456747970064),  bigInt(-1130523020145965072),  bigInt(-1126544775367125264),
		bigInt(-1122572703197093136),  bigInt(-1118606784510809872),  bigInt(-1114647000271965200),  bigInt(-1110693331532447504),  bigInt(-1106745759431800336),
		bigInt(-1102804265196682768),  bigInt(-1098868830140333328),  bigInt(-1094939435662039056),  bigInt(-1091016063246607120),  bigInt(-1087098694463842064),
		bigInt(-1083187310968025616),  bigInt(-1079281894497402640),  bigInt(-1075382426873667600),  bigInt(-1071488890001458704),  bigInt(-1067601265867852048),
		bigInt(-1063719536541864208),  bigInt(-1059843684173953808),  bigInt(-1055973690995529488),  bigInt(-1052109539318462480),  bigInt(-1048251211534599952),
		bigInt(-1044398690115283984),  bigInt(-1040551957610874384),  bigInt(-1036710996650273808),  bigInt(-1032875789940457488),  bigInt(-1029046320266005776),
		bigInt(-1025222570488640528),  bigInt(-1021404523546765328),  bigInt(-1017592162455007760),  bigInt(-1013785470303767312),  bigInt(-1009984430258764560),
		bigInt(-1006189025560594192),  bigInt(-1002399239524282640),  bigInt(-998615055538846736),  bigInt(-994836457066858000),  bigInt(-991063427644008464),
		bigInt(-987295950878680592),  bigInt(-983534010451518992),  bigInt(-979777590115007760),  bigInt(-976026673693048080),  bigInt(-972281245080541456),
		bigInt(-968541288242973968),  bigInt(-964806787216004368),  bigInt(-961077726105056272),  bigInt(-957354089084910864),  bigInt(-953635860399304720),
		bigInt(-949923024360529680),  bigInt(-946215565349035792),  bigInt(-942513467813036560),  bigInt(-938816716268118288),  bigInt(-935125295296851216),
		bigInt(-931439189548402704),  bigInt(-927758383738156304),  bigInt(-924082862647329552),  bigInt(-9204126111225973009),  bigInt(-9167476140757165841),
		bigInt(-9130878564831548689),  bigInt(-9094333233857201937),  bigInt(-9057839998881943569),  bigInt(-9021398711589686801),  bigInt(-8985009224296822801),
		bigInt(-8948671389948630801),  bigInt(-8912385062115711249),  bigInt(-8876150094990445841),  bigInt(-8839966343383482385),  bigInt(-8803833662720244241),
		bigInt(-8767751909037464081),  bigInt(-8731720938979741969),  bigInt(-8695740609796128785),  bigInt(-8659810779336732433),  bigInt(-8623931306049348113),
		bigInt(-8588102048976112401),  bigInt(-8552322867750180625),  bigInt(-8516593622592427025),  bigInt(-8480914174308169233),  bigInt(-8445284384283912977),
		bigInt(-8409704114484122897),  bigInt(-8374173227448012049),  bigInt(-8338691586286356753),  bigInt(-8303259054678332433),  bigInt(-8267875496868369425),
		bigInt(-8232540777663034129),  bigInt(-8197254762427928337),  bigInt(-8162017317084612625),  bigInt(-8126828308107547409),  bigInt(-8091687602521059601),
		bigInt(-8056595067896325905),  bigInt(-8021550572348378641),  bigInt(-7986553984533132305),  bigInt(-7951605173644430097),  bigInt(-7916704009411109393),
		bigInt(-7881850362094089489),  bigInt(-7847044102483476497),  bigInt(-7812285101895691281),  bigInt(-7777573232170612497),  bigInt(-7742908365668742929),
		bigInt(-7708290375268392977),  bigInt(-7673719134362883857),  bigInt(-7639194516857768721),  bigInt(-7604716397168073745),  bigInt(-7570284650215556625),
		bigInt(-7535899151425984785),  bigInt(-7501559776726430481),  bigInt(-7467266402542585361),  bigInt(-7433018905796090897),  bigInt(-7398817163901889553),
		bigInt(-7364661054765591569),  bigInt(-7330550456780858897),  bigInt(-7296485248826808849),  bigInt(-7262465310265432593),  bigInt(-7228490520939032849),
		bigInt(-7194560761167675921),  bigInt(-7160675911746663441),  bigInt(-7126835853944019729),  bigInt(-7093040469497993745),  bigInt(-7059289640614582289),
		bigInt(-7025583249965063185),  bigInt(-6991921180683550993),  bigInt(-6958303316364563729),  bigInt(-6924729541060609041),  bigInt(-6891199739279783697),
		bigInt(-6857713795983390737),  bigInt(-6824271596583570961),  bigInt(-6790873026940950033),  bigInt(-6757517973362300945),  bigInt(-6724206322598222609),
		bigInt(-6690937961840832273),  bigInt(-6657712778721473297),  bigInt(-6624530661308438289),  bigInt(-6591391498104706065),  bigInt(-6558295178045694225),
		bigInt(-6525241590497025297),  bigInt(-6492230625252308241),  bigInt(-6459262172530933777),  bigInt(-6426336122975883281),  bigInt(-6393452367651552785),
		bigInt(-6360610798041590289),  bigInt(-6327811306046747665),  bigInt(-6295053783982744593),  bigInt(-6262338124578148881),  bigInt(-6229664220972267281),
		bigInt(-6197031966713052433),  bigInt(-6164441255755020817),  bigInt(-6131891982457185553),  bigInt(-6099384041581002769),  bigInt(-6066917328288327697),
		bigInt(-6034491738139388433),  bigInt(-6002107167090769169),  bigInt(-5969763511493406481),  bigInt(-5937460668090599953),  bigInt(-5905198534016033809),
		bigInt(-5872977006791811601),  bigInt(-5840795984326503185),  bigInt(-5808655364913203217),  bigInt(-5776555047227603985),  bigInt(-5744494930326076689),
		bigInt(-5712474913643769617),  bigInt(-5680494896992712209),  bigInt(-5648554780559937297),  bigInt(-5616654464905609489),  bigInt(-5584793850961169169),
		bigInt(-5552972840027485969),  bigInt(-5521191333773024017),  bigInt(-5489449234232018961),  bigInt(-5457746443802666513),  bigInt(-5426082865245320977),
		bigInt(-5394458401680706321),  bigInt(-5362872956588137489),  bigInt(-5331326433803752721),  bigInt(-5299818737518757137),  bigInt(-5268349772277676561),
		bigInt(-5236919442976622865),  bigInt(-5205527654861568785),  bigInt(-5174174313526634513),  bigInt(-5142859324912383761),  bigInt(-5111582595304131089),
		bigInt(-5080344031330258961),  bigInt(-5049143539960545809),  bigInt(-5017981028504502545),  bigInt(-4986856404609721105),  bigInt(-4955769576260232721),
		bigInt(-4924720451774875153),  bigInt(-4893708939805669905),  bigInt(-4862734949336210705),  bigInt(-4831798389680060177),  bigInt(-4800899170479157009),
		bigInt(-4770037201702231825),  bigInt(-4739212393643234577),  bigInt(-4708424656919768337),  bigInt(-4677673902471535377),  bigInt(-4646960041558791185),
		bigInt(-4616282985760807953),  bigInt(-4585642646974346769),  bigInt(-4555038937412140049),  bigInt(-4524471769601382417),  bigInt(-4493941056382230033),
		bigInt(-4463446710906310161),  bigInt(-4432988646635238161),  bigInt(-4402566777339144209),  bigInt(-4372181017095208721),  bigInt(-4341831280286206225),
		bigInt(-4311517481599057937),  bigInt(-4281239536023392273),  bigInt(-4250997358850115857),  bigInt(-4220790865669989649),  bigInt(-4190619972372217105),
		bigInt(-4160484595143037457),  bigInt(-4130384650464330513),  bigInt(-4100320055112225553),  bigInt(-4070290726155722769),  bigInt(-4040296580955319825),
		bigInt(-4010337537161646609),  bigInt(-3980413512714110481),  bigInt(-3950524425839545617),  bigInt(-3920670195050873873),  bigInt(-3890850739145770769),
		bigInt(-3861065977205340945),  bigInt(-3831315828592799761),  bigInt(-3801600212952164881),  bigInt(-3771919050206952977),  bigInt(-3742272260558884369),
		bigInt(-3712659764486597649),  bigInt(-3683081482744368401),  bigInt(-3653537336360836881),  bigInt(-3624027246637743889),  bigInt(-3594551135148672017),
		bigInt(-3565108923737795601),  bigInt(-3535700534518636817),  bigInt(-3506325889872829713),  bigInt(-3476984912448891921),  bigInt(-3447677525161000465),
		bigInt(-3418403651187778833),  bigInt(-3389163213971087377),  bigInt(-3359956137214822417),  bigInt(-3330782344883721745),  bigInt(-3301641761202177041),
		bigInt(-3272534310653053201),  bigInt(-3243459917976512785),  bigInt(-3214418508168850961),  bigInt(-3185410006481331985),  bigInt(-3156434338419036433),
		bigInt(-3127491429739712785),  bigInt(-3098581206452635921),  bigInt(-3069703594817473297),  bigInt(-3040858521343154705),  bigInt(-3012045912786750993),
		bigInt(-2983265696152358929),  bigInt(-2954517798689989905),  bigInt(-2925802147894468113),  bigInt(-2897118671504332817),  bigInt(-2868467297500746257),
		bigInt(-2839847954106410769),  bigInt(-2811260569784488209),  bigInt(-2782705073237527569),  bigInt(-2754181393406398481),  bigInt(-2725689459469229329),
		bigInt(-2697229200840353041),  bigInt(-2668800547169257745),  bigInt(-2640403428339542545),  bigInt(-2612037774467881489),  bigInt(-2583703515902990097),
		bigInt(-2555400583224599569),  bigInt(-2527128907242437393),  bigInt(-2498888418995211281),  bigInt(-2470679049749600017),  bigInt(-2442500730999250193),
		bigInt(-2414353394463777809),  bigInt(-2386236972087775249),  bigInt(-2358151396039824657),  bigInt(-2330096598711515409),  bigInt(-2302072512716467985),
		bigInt(-2274079070889362705),  bigInt(-2246116206284973329),  bigInt(-2218183852177208081),  bigInt(-2190281942058152465),  bigInt(-2162410409637119761),
		bigInt(-2134569188839706897),  bigInt(-2106758213806853137),  bigInt(-2078977418893906193),  bigInt(-2051226738669692945),  bigInt(-2023506107915593745),
		bigInt(-1995815461624623377),  bigInt(-1968154735000516113),  bigInt(-1940523863456816401),  bigInt(-1912922782615973649),  bigInt(-1885351428308442129),
		bigInt(-1857809736571786769),  bigInt(-1830297643649791249),  bigInt(-1802815085991574033),  bigInt(-1775362000250706449),  bigInt(-1747938323284337169),
		bigInt(-1720543992152321041),  bigInt(-1693178944116351761),  bigInt(-1665843116639100177),  bigInt(-1638536447383356689),  bigInt(-1611258874211177745),
		bigInt(-1584010335183038993),  bigInt(-1556790768556989713),  bigInt(-1529600112787813905),  bigInt(-1502438306526196497),  bigInt(-1475305288617890577),
		bigInt(-1448200998102893841),  bigInt(-1421125374214624529),  bigInt(-1394078356379105297),  bigInt(-1367059884214150161),  bigInt(-1340069897528555025),
		bigInt(-1313108336321293329),  bigInt(-1286175140780716561),  bigInt(-1259270251283756305),  bigInt(-1232393608395134225),  bigInt(-1205545152866573329),
		bigInt(-1178724825636013841),  bigInt(-1151932567826835473),  bigInt(-1125168320747079185),  bigInt(-1098432025888678417),  bigInt(-1071723624926689809),
		bigInt(-1045043059718531089),  bigInt(-1018390272303220497),  bigInt(-991765204900622097),  bigInt(-965167799910694161),  bigInt(-938597999912740625),
		bigInt(-9120557476646688018),  bigInt(-8855409861022477842),  bigInt(-8590536583383737618),  bigInt(-8325937076623368978),  bigInt(-8061610775390929682),
		bigInt(-7797557116085387538),  bigInt(-7533775536847907858),  bigInt(-7270265477554681618),  bigInt(-7007026379809789202),  bigInt(-6744057686938099474),
		bigInt(-6481358843978207762),  bigInt(-6218929297675408658),  bigInt(-5956768496474703634),  bigInt(-5694875890513847314),  bigInt(-5433250931616427282),
		bigInt(-5171893073284978450),  bigInt(-4910801770694135826),  bigInt(-4649976480683817746),  bigInt(-4389416661752447762),  bigInt(-4129121774050208786),
		bigInt(-3869091279372331538),  bigInt(-3609324641152418322),  bigInt(-3349821324455799826),  bigInt(-3090580795972924434),  bigInt(-2831602524012783890),
		bigInt(-2572885978496368658),  bigInt(-2314430630950159634),  bigInt(-2056235954499650066),  bigInt(-1798301423862901522),  bigInt(-1540626515344131858),
		bigInt(-1283210706827335954),  bigInt(-1026053477769937170),  bigInt(-7691543091964727571),  bigInt(-5125126836923077907),  bigInt(-2561280853973845523),
		bigInt(237),  bigInt(2558720852693845229),  bigInt(5114886816443023597),  bigInt(7668502988284105965),  bigInt(1021957445001588206),
		bigInt(1276810626826003182),  bigInt(1531410349452151022),  bigInt(1785757116524862190),  bigInt(2039851430189279982),  bigInt(2293693791096807662),
		bigInt(2547284698411029486),  bigInt(2800624649813597422),  bigInt(3053714141510093550),  bigInt(3306553668235860206),  bigInt(3559143723261804014),
		bigInt(3811484798400167918),  bigInt(4063577384010278382),  bigInt(4315421969004262382),  bigInt(4567019040852736238),  bigInt(4818369085590467054),
		bigInt(5069472587822006766),  bigInt(5320330030727297262),  bigInt(5570941896067249390),  bigInt(5821308664189294062),  bigInt(6071430814032906990),
		bigInt(6321308823135104494),  bigInt(6570943167635914990),  bigInt(6820334322283821806),  bigInt(7069482760441181678),  bigInt(7318388954089614318),
		bigInt(7567053373835367406),  bigInt(7815476488914655726),  bigInt(8063658767198973934),  bigInt(8311600675200382958),  bigInt(8559302678076771566),
		bigInt(8806765239637093614),  bigInt(9053988822346577134),  bigInt(930097388733191407),  bigInt(954772089438640879),  bigInt(979423030197512943),
		bigInt(1004050256724001519),  bigInt(1028653814600495087),  bigInt(1053233749278084847),  bigInt(1077790106077066223),  bigInt(1102322930187442927),
		bigInt(1126832266669423087),  bigInt(1151318160453917935),  bigInt(1175780656343035119),  bigInt(1200219799010570991),  bigInt(1224635633002499311),
		bigInt(1249028202737459439),  bigInt(1273397552507240431),  bigInt(1297743726477264111),  bigInt(1322066768687064559),  bigInt(1346366723050767087),
		bigInt(1370643633357563631),  bigInt(1394897543272185327),  bigInt(1419128496335375087),  bigInt(1443336535964355823),  bigInt(1467521705453297135),
		bigInt(1491684047973780207),  bigInt(1515823606575259887),  bigInt(1539940424185525743),  bigInt(1564034543611158767),  bigInt(1588106007537987823),
		bigInt(1612154858531544303),  bigInt(1636181139037511919),  bigInt(1660184891382177775),  bigInt(1684166157772879599),  bigInt(1708124980298449391),
		bigInt(1732061400929659375),  bigInt(1755975461519660271),  bigInt(1779867203804422639),  bigInt(1803736669403172591),  bigInt(1827583899818827503),
		bigInt(1851408936438428911),  bigInt(1875211820533572591),  bigInt(1898992593260838895),  bigInt(1922751295662218735),  bigInt(1946487968665539055),
		bigInt(1970202653084885231),  bigInt(1993895389621023727),  bigInt(2017566218861818607),  bigInt(2041215181282651375),  bigInt(2064842317246834671),
		bigInt(2088447667006025711),  bigInt(2112031270700638959),  bigInt(2135593168360253423),  bigInt(2159133399904022767),  bigInt(2182652005141079791),
		bigInt(2206149023770939887),  bigInt(2229624495383904751),  bigInt(2253078459461460719),  bigInt(2276510955376678895),  bigInt(2299922022394610415),
		bigInt(2323311699672682223),  bigInt(2346680026261089263),  bigInt(2370027041103185903),  bigInt(2393352783035875823),  bigInt(2416657290789998575),
		bigInt(2439940602990716655),  bigInt(2463202758157898735),  bigInt(2486443794706502383),  bigInt(2509663750946954991),  bigInt(2532862665085531631),
		bigInt(2556040575224733423),  bigInt(2579197519363662575),  bigInt(2602333535398395887),  bigInt(2625448661122357231),  bigInt(2648542934226687727),
		bigInt(2671616392300615151),  bigInt(2694669072831819503),  bigInt(2717701013206800367),  bigInt(2740712250711239407),  bigInt(2763702822530362607),
		bigInt(2786672765749301487),  bigInt(2809622117353451759),  bigInt(2832550914228829935),  bigInt(2855459193162430191),  bigInt(2878346990842577647),
		bigInt(2901214343859281391),  bigInt(2924061288704585455),  bigInt(2946887861772917231),  bigInt(2969694099361437167),  bigInt(2992480037670383087),
		bigInt(3015245712803416559),  bigInt(3037991160767965423),  bigInt(3060716417475565039),  bigInt(3083421518742199279),  bigInt(3106106500288639471),
		bigInt(3128771397740779759),  bigInt(3151416246629975279),  bigInt(3174041082393374703),  bigInt(3196645940374253295),  bigInt(3219230855822344687),
		bigInt(3241795863894169839),  bigInt(3264340999653366255),  bigInt(3286866298071014383),  bigInt(3309371794025963247),  bigInt(3331857522305154543),
		bigInt(3354323517603944943),  bigInt(3376769814526428143),  bigInt(3399196447585753071),  bigInt(3421603451204444399),  bigInt(3443990859714717935),
		bigInt(3466358707358796271),  bigInt(3488707028289224431),  bigInt(3511035856569181423),  bigInt(3533345226172792047),  bigInt(3555635170985437167),
		bigInt(3577905724804062959),  bigInt(3600156921337487343),  bigInt(3622388794206707439),  bigInt(3644601376945202671),  bigInt(3666794702999240431),
		bigInt(3688968805728175855),  bigInt(3711123718404754927),  bigInt(3733259474215411951),  bigInt(3755376106260569839),  bigInt(3777473647554935535),
		bigInt(3799552131027796207),  bigInt(3821611589523314159),  bigInt(3843652055800819183),  bigInt(3865673562535100911),  bigInt(3887676142316699887),
		bigInt(3909659827652195823),  bigInt(3931624650964496623),  bigInt(3953570644593124847),  bigInt(3975497840794504175),  bigInt(3997406271742243055),
		bigInt(4019295969527417839),  bigInt(4041166966158855663),  bigInt(4063019293563414511),  bigInt(4084852983586263535),  bigInt(4106668067991160815),
		bigInt(4128464578460730607),  bigInt(4150242546596740847),  bigInt(4172002003920375791),  bigInt(4193742981872511215),  bigInt(4215465511813987311),
		bigInt(4237169625025879023),  bigInt(4258855352709766639),  bigInt(4280522725988005615),  bigInt(4302171775903993327),  bigInt(4323802533422437103),
		bigInt(4345415029429619695),  bigInt(4367009294733663215),  bigInt(4388585360064793583),  bigInt(4410143256075601903),  bigInt(4431683013341306607),
		bigInt(4453204662360013551),  bigInt(4474708233552974319),  bigInt(4496193757264845551),  bigInt(4517661263763944175),  bigInt(4539110783242504943),
		bigInt(4560542345816934383),  bigInt(4581955981528063983),  bigInt(4603351720341404399),  bigInt(4624729592147395055),  bigInt(4646089626761656303),
		bigInt(4667431853925238767),  bigInt(4688756303304870383),  bigInt(4710063004493205743),  bigInt(4731351987009071087),  bigInt(4752623280297710319),
		bigInt(4773876913731029231),  bigInt(4795112916607838959),  bigInt(4816331318154098159),  bigInt(4837532147523154159),  bigInt(4858715433795984111),
		bigInt(4879881205981433071),  bigInt(4901029493016453359),  bigInt(4922160323766341615),  bigInt(4943273727024975087),  bigInt(4964369731515047151),
		bigInt(4985448365888301807),  bigInt(5006509658725766895),  bigInt(5027553638537987311),  bigInt(5048580333765255407),  bigInt(5069589772777842671),
		bigInt(5090581983876229103),  bigInt(5111556995291331567),  bigInt(5132514835184731887),  bigInt(5153455531648903919),  bigInt(5174379112707439343),
		bigInt(5195285606315272175),  bigInt(5216175040358903535),  bigInt(5237047442656624623),  bigInt(5257902840958738671),  bigInt(5278741262947783151),
		bigInt(5299562736238749167),  bigInt(5320367288379301615),  bigInt(5341154946849997807),  bigInt(5361925739064505839),  bigInt(5382679692369819631),
		bigInt(5403416834046477551),  bigInt(5424137191308775407),  bigInt(5444840791304981999),  bigInt(5465527661117551855),  bigInt(5486197827763338479),
		bigInt(5506851318193805039),  bigInt(5527488159295236335),  bigInt(5548108377888947951),  bigInt(5568712000731496175),  bigInt(5589299054514885359),
		bigInt(5609869565866776303),  bigInt(5630423561350692079),  bigInt(5650961067466224879),  bigInt(5671482110649239791),  bigInt(5691986717272080111),
		bigInt(5712474913643770095),  bigInt(5732946726010216943),  bigInt(5753402180554413807),  bigInt(5773841303396640239),  bigInt(5794264120594661359),
		bigInt(5814670658143928815),  bigInt(5835060941977777647),  bigInt(5855434997967625711),  bigInt(5875792851923169007),  bigInt(5896134529592579055),
		bigInt(5916460056662697967),  bigInt(5936769458759232495),  bigInt(5957062761446948335),  bigInt(5977339990229864175),  bigInt(5997601170551441647),
		bigInt(6017846327794779375),  bigInt(6038075487282801903),  bigInt(6058288674278451439),  bigInt(6078485913984875247),  bigInt(6098667231545615855),
		bigInt(6118832652044797935),  bigInt(6138982200507315439),  bigInt(6159115901899018479),  bigInt(6179233781126898671),  bigInt(6199335863039273199),
		bigInt(6219422172425970671),  bigInt(6239492734018512623),  bigInt(6259547572490297583),  bigInt(6279586712456782575),  bigInt(6299610178475664623),
		bigInt(6319617995047060719),  bigInt(6339610186613688303),  bigInt(6359586777561044719),  bigInt(6379547792217584367),  bigInt(6399493254854897647),
		bigInt(6419423189687888111),  bigInt(6439337620874947823),  bigInt(6459236572518134255),  bigInt(6479120068663344111),  bigInt(6498988133300488943),
		bigInt(6518840790363667439),  bigInt(6538678063731339759),  bigInt(6558499977226499055),  bigInt(6578306554616843247),  bigInt(6598097819614946031),
		bigInt(6617873795878427631),  bigInt(6637634507010123759),  bigInt(6657379976558255087),  bigInt(6677110228016595439),  bigInt(6696825284824639983),
		bigInt(6716525170367771119),  bigInt(6736209907977426671),  bigInt(6755879520931264239),  bigInt(6775534032453326831),  bigInt(6795173465714207215),
		bigInt(6814797843831212527),  bigInt(6834407189868526831),  bigInt(6854001526837373679),  bigInt(6873580877696178415),  bigInt(6893145265350729967),
		bigInt(6912694712654340847),  bigInt(6932229242408007663),  bigInt(6951748877360571119),  bigInt(6971253640208873967),  bigInt(6990743553597920751),
		bigInt(7010218640121033711),  bigInt(7029678922320012015),  bigInt(7049124422685286383),  bigInt(7068555163656076527),  bigInt(7087971167620545519),
		bigInt(7107372456915955183),  bigInt(7126759053828819951),  bigInt(7146130980595060463),  bigInt(7165488259400157167),  bigInt(7184830912379301871),
		bigInt(7204158961617549807),  bigInt(7223472429149971951),  bigInt(7242771336961804015),  bigInt(7262055706988598255),  bigInt(7281325561116372207),
		bigInt(7300580921181757679),  bigInt(7319821808972149487),  bigInt(7339048246225853423),  bigInt(7358260254632233711),  bigInt(7377457855831858927),
		bigInt(7396641071416649199),  bigInt(7415809922930022127),  bigInt(7434964431867037167),  bigInt(7454104619674540015),  bigInt(7473230507751307759),
		bigInt(7492342117448192239),  bigInt(7511439470068261871),  bigInt(7530522586866945519),  bigInt(7549591489052173551),  bigInt(7568646197784519919),
		bigInt(7587686734177342447),  bigInt(7606713119296923375),  bigInt(7625725374162609647),  bigInt(7644723519746951663),  bigInt(7663707576975842287),
		bigInt(7682677566728655087),  bigInt(7701633509838382319),  bigInt(7720575427091772399),  bigInt(7739503339229465583),  bigInt(7758417266946131439),
		bigInt(7777317230890604271),  bigInt(7796203251666018287),  bigInt(7815075349829941743),  bigInt(7833933545894512367),  bigInt(7852777860326570735),
		bigInt(7871608313547792623),  bigInt(7890424925934823151),  bigInt(7909227717819408111),  bigInt(7928016709488526575),  bigInt(7946791921184521455),
		bigInt(7965553373105230575),  bigInt(7984301085404117231),  bigInt(8003035078190400495),  bigInt(8021755371529183471),  bigInt(8040461985441583343),
		bigInt(8059154939904859119),  bigInt(8077834254852540143),  bigInt(8096499950174553327),  bigInt(8115152045717350639),  bigInt(8133790561284034799),
		bigInt(8152415516634486511),  bigInt(8171026931485489391),  bigInt(8189624825510855663),  bigInt(8208209218341551087),  bigInt(8226780129565818095),
		bigInt(8245337578729301231),  bigInt(8263881585335170031),  bigInt(8282412168844240879),  bigInt(8300929348675101935),  bigInt(8319433144204232431),
		bigInt(8337923574766126831),  bigInt(8356400659653414383),  bigInt(8374864418116980463),  bigInt(8393314869366086895),  bigInt(8411752032568492015),
		bigInt(8430175926850570223),  bigInt(8448586571297430255),  bigInt(8466983984953034479),  bigInt(8485368186820317679),  bigInt(8503739195861303023),
		bigInt(8522097030997221359),  bigInt(8540441711108626927),  bigInt(8558773255035514351),  bigInt(8577091681577434095),  bigInt(8595397009493609711),
		bigInt(8613689257503051247),  bigInt(8631968444284670959),  bigInt(8650234588477397999),  bigInt(8668487708680291823),  bigInt(8686727823452656367),
		bigInt(8704954951314152943),  bigInt(8723169110744913135),  bigInt(8741370320185651439),  bigInt(8759558598037777135),  bigInt(8777733962663505135),
		bigInt(8795896432385969135),  bigInt(8814046025489330159),  bigInt(8832182760218888687),  bigInt(8850306654781194223),  bigInt(8868417727344154095),
		bigInt(8886515996037144559),  bigInt(8904601478951117551),  bigInt(8922674194138710767),  bigInt(8940734159614355695),  bigInt(8958781393354383855),
		bigInt(8976815913297135855),  bigInt(8994837737343068143),  bigInt(9012846883354857967),  bigInt(9030843369157512431),  bigInt(9048827212538471151),
		bigInt(9066798431247714799),  bigInt(9084757042997867503),  bigInt(9102703065464303855),  bigInt(9120636516285251823),  bigInt(9138557413061897199),
		bigInt(9156465773358487535),  bigInt(9174361614702435055),  bigInt(9192244954584419311),  bigInt(9210115810458491119),  bigInt(922797419974217456),
		bigInt(924582013981656304),  bigInt(926365364802643184),  bigInt(928147474168033264),  bigInt(929928343805068784),  bigInt(931707975437391088),
		bigInt(933486370785048048),  bigInt(935263531564505840),  bigInt(937039459488658928),  bigInt(938814156266838768),  bigInt(940587623604824560),
		bigInt(942359863204852720),  bigInt(944130876765626864),  bigInt(945900665982328048),  bigInt(947669232546623216),  bigInt(949436578146676208),
		bigInt(951202704467156720),  bigInt(952967613189250288),  bigInt(954731305990667248),  bigInt(956493784545653744),  bigInt(958255050524998896),
		bigInt(960015105596047088),  bigInt(961773951422705392),  bigInt(963531589665453808),  bigInt(965288021981354224),  bigInt(967043250024060656),
		bigInt(968797275443827696),  bigInt(970550099887519984),  bigInt(972301724998622448),  bigInt(974052152417247728),  bigInt(975801383780146928),
		bigInt(977549420720718576),  bigInt(979296264869017072),  bigInt(981041917851762672),  bigInt(982786381292349168),  bigInt(984529656810855408),
		bigInt(986271746024051184),  bigInt(988012650545409520),  bigInt(989752371985112560),  bigInt(991490911950062832),  bigInt(993228272043891184),
		bigInt(994964453866964976),  bigInt(996699459016399088),  bigInt(998433289086061552),  bigInt(1000165945666585840),  bigInt(1001897430345376752),
		bigInt(1003627744706620912),  bigInt(1005356890331294192),  bigInt(1007084868797171696),  bigInt(1008811681678835440),  bigInt(1010537330547683312),
		bigInt(1012261816971937264),  bigInt(1013985142516652784),  bigInt(1015707308743726320),  bigInt(1017428317211904496),  bigInt(1019148169476792304),
		bigInt(1020866867090861808),  bigInt(1022584411603459824),  bigInt(1024300804560817136),  bigInt(1026016047506056688),  bigInt(1027730141979201776),
		bigInt(1029443089517183472),  bigInt(1031154891653851120),  bigInt(1032865549919977968),  bigInt(1034575065843271152),  bigInt(1036283440948379632),
		bigInt(1037990676756901104),  bigInt(1039696774787391984),  bigInt(1041401736555374320),  bigInt(1043105563573343984),  bigInt(1044808257350779376),
		bigInt(1046509819394148336),  bigInt(1048210251206916848),  bigInt(1049909554289557744),  bigInt(1051607730139556848),  bigInt(1053304780251422448),
		bigInt(1055000706116692720),  bigInt(1056695509223942640),  bigInt(1058389191058793968),  bigInt(1060081753103920624),  bigInt(1061773196839058160),
		bigInt(1063463523741011440),  bigInt(1065152735283660784),  bigInt(1066840832937971952),  bigInt(1068527818172002032),  bigInt(1070213692450907888),
		bigInt(1071898457236953840),  bigInt(1073582113989519088),  bigInt(1075264664165105136),  bigInt(1076946109217343728),  bigInt(1078626450597003760),
		bigInt(1080305689751999984),  bigInt(1081983828127399408),  bigInt(1083660867165428464),  bigInt(1085336808305481712),  bigInt(1087011652984128752),
		bigInt(1088685402635121136),  bigInt(1090358058689399792),  bigInt(1092029622575103216),  bigInt(1093700095717573616),  bigInt(1095369479539365104),
		bigInt(1097037775460251120),  bigInt(1098704984897230064),  bigInt(1100371109264534768),  bigInt(1102036149973637872),  bigInt(1103700108433260272),
		bigInt(1105362986049377008),  bigInt(1107024784225225712),  bigInt(1108685504361312752),  bigInt(1110345147855421168),  bigInt(1112003716102616304),
		bigInt(1113661210495254768),  bigInt(1115317632422989552),  bigInt(1116972983272778736),  bigInt(1118627264428890864),  bigInt(1120280477272913136),
		bigInt(1121932623183757808),  bigInt(1123583703537668848),  bigInt(1125233719708229360),  bigInt(1126882673066368240),  bigInt(1128530564980366832),
		bigInt(1130177396815865840),  bigInt(1131823169935871984),  bigInt(1133467885700765168),  bigInt(1135111545468304880),  bigInt(1136754150593637360),
		bigInt(1138395702429301232),  bigInt(1140036202325235440),  bigInt(1141675651628785392),  bigInt(1143314051684709616),  bigInt(1144951403835185648),
		bigInt(1146587709419818480),  bigInt(1148222969775645424),  bigInt(1149857186237142768),  bigInt(1151490360136233456),  bigInt(1153122492802292720),
		bigInt(1154753585562154992),  bigInt(1156383639740119536),  bigInt(1158012656657958128),  bigInt(1159640637634920688),  bigInt(1161267583987741680),
		bigInt(1162893497030647024),  bigInt(1164518378075359984),  bigInt(1166142228431107568),  bigInt(1167765049404627440),  bigInt(1169386842300173040),
		bigInt(1171007608419521264),  bigInt(1172627349061977840),  bigInt(1174246065524383216),  bigInt(1175863759101120496),  bigInt(1177480431084119536),
		bigInt(1179096082762864624),  bigInt(1180710715424400112),  bigInt(1182324330353336560),  bigInt(1183936928831856880),  bigInt(1185548512139722224),
		bigInt(1187159081554279152),  bigInt(1188768638350463728),  bigInt(1190377183800809968),  bigInt(1191984719175453680),  bigInt(1193591245742139888),
		bigInt(1195196764766228464),  bigInt(1196801277510699760),  bigInt(1198404785236161264),  bigInt(1200007289200852464),  bigInt(1201608790660652272),
		bigInt(1203209290869083376),  bigInt(1204808791077318896),  bigInt(1206407292534189040),  bigInt(1208004796486184944),  bigInt(1209601304177466608),
		bigInt(1211196816849866992),  bigInt(1212791335742899184),  bigInt(1214384862093761520),  bigInt(1215977397137343216),  bigInt(1217568942106230512),
		bigInt(1219159498230711536),  bigInt(1220749066738783728),  bigInt(1222337648856157680),  bigInt(1223925245806264048),  bigInt(1225511858810258416),
		bigInt(1227097489087027184),  bigInt(1228682137853193456),  bigInt(1230265806323122928),  bigInt(1231848495708927984),  bigInt(1233430207220475376),
		bigInt(1235010942065389552),  bigInt(1236590701449060336),  bigInt(1238169486574646512),  bigInt(1239747298643082992),  bigInt(1241324138853084912),
		bigInt(1242900008401154288),  bigInt(1244474908481584368),  bigInt(1246048840286466032),  bigInt(1247621805005692656),  bigInt(1249193803826964976),
		bigInt(1250764837935798000),  bigInt(1252334908515524848),  bigInt(1253904016747303408),  bigInt(1255472163810120176),  bigInt(1257039350880796656),
		bigInt(1258605579133994992),  bigInt(1260170849742221808),  bigInt(1261735163875834864),  bigInt(1263298522703047152),  bigInt(1264860927389933296),
		bigInt(1266422379100434416),  bigInt(1267982878996361968),  bigInt(1269542428237405680),  bigInt(1271101027981135600),  bigInt(1272658679383010032),
		bigInt(1274215383596378352),  bigInt(1275771141772488176),  bigInt(1277325955060488688),  bigInt(1278879824607437040),  bigInt(1280432751558302704),
		bigInt(1281984737055972592),  bigInt(1283535782241257200),  bigInt(1285085888252893168),  bigInt(1286635056227551216),  bigInt(1288183287299839216),
		bigInt(1289730582602307312),  bigInt(1291276943265454064),  bigInt(1292822370417730544),  bigInt(1294366865185544432),  bigInt(1295910428693267184),
		bigInt(1297453062063237104),  bigInt(1298994766415764208),  bigInt(1300535542869136624),  bigInt(1302075392539624176),  bigInt(1303614316541483248),
		bigInt(1305152315986962416),  bigInt(1306689391986306544),  bigInt(1308225545647761904),  bigInt(1309760778077581040),  bigInt(1311295090380027120),
		bigInt(1312828483657379312),  bigInt(1314360959009937392),  bigInt(1315892517536025584),  bigInt(1317423160331998704),  bigInt(1318952888492246256),
		bigInt(1320481703109196528),  bigInt(1322009605273321968),  bigInt(1323536596073144048),  bigInt(1325062676595237104),  bigInt(1326587847924233968),
		bigInt(1328112111142829296),  bigInt(1329635467331785456),  bigInt(1331157917569936368),  bigInt(1332679462934192880),  bigInt(1334200104499545840),
		bigInt(1335719843339072240),  bigInt(1337238680523939312),  bigInt(1338756617123408112),  bigInt(1340273654204839664),  bigInt(1341789792833697520),
		bigInt(1343305034073554416),  bigInt(1344819378986094832),  bigInt(1346332828631120880),  bigInt(1347845384066555888),  bigInt(1349357046348448752),
		bigInt(1350867816530979056),  bigInt(1352377695666461168),  bigInt(1353886684805348848),  bigInt(1355394784996238576),  bigInt(1356901997285875440),
		bigInt(1358408322719156464),  bigInt(1359913762339135472),  bigInt(1361418317187027184),  bigInt(1362921988302211312),  bigInt(1364424776722237680),
		bigInt(1365926683482829296),  bigInt(1367427709617887984),  bigInt(1368927856159497456),  bigInt(1370427124137928176),  bigInt(1371925514581641968),
		bigInt(1373423028517295600),  bigInt(1374919666969744624),  bigInt(1376415430962049264),  bigInt(1377910321515476464),  bigInt(1379404339649505520),
		bigInt(1380897486381832432),  bigInt(1382389762728372720),  bigInt(1383881169703266800),  bigInt(1385371708318883056),  bigInt(1386861379585823472),
		bigInt(1388350184512926192),  bigInt(1389838124107270384),  bigInt(1391325199374180336),  bigInt(1392811411317229296),  bigInt(1394296760938243824),
		bigInt(1395781249237307376),  bigInt(1397264877212764912),  bigInt(1398747645861226480),  bigInt(1400229556177571824),  bigInt(1401710609154952944),
		bigInt(1403190805784800496),  bigInt(1404670147056825072),  bigInt(1406148633959023344),  bigInt(1407626267477680880),  bigInt(1409103048597376496),
		bigInt(1410578978300985840),  bigInt(1412054057569685744),  bigInt(1413528287382958064),  bigInt(1415001668718593008),  bigInt(1416474202552694000),
		bigInt(1417945889859680752),  bigInt(1419416731612293360),  bigInt(1420886728781596656),  bigInt(1422355882336983024),  bigInt(1423824193246177264),
		bigInt(1425291662475239920),  bigInt(1426758290988571120),  bigInt(1428224079748914160),  bigInt(1429689029717360112),  bigInt(1431153141853350640),
		bigInt(1432616417114682352),  bigInt(1434078856457510128),  bigInt(1435540460836351472),  bigInt(1437001231204089584),  bigInt(1438461168511977968),
		bigInt(1439920273709642736),  bigInt(1441378547745087984),  bigInt(1442835991564698096),  bigInt(1444292606113242608),  bigInt(1445748392333878256),
		bigInt(1447203351168154864),  bigInt(1448657483556017136),  bigInt(1450110790435809008),  bigInt(1451563272744277232),  bigInt(1453014931416575216),
		bigInt(1454465767386266096),  bigInt(1455915781585327088),  bigInt(1457364974944152048),  bigInt(1458813348391556592),  bigInt(1460260902854779632),
		bigInt(1461707639259489008),  bigInt(1463153558529783280),  bigInt(1464598661588196592),  bigInt(1466042949355701488),  bigInt(1467486422751712752),
		bigInt(1468929082694090736),  bigInt(1470370930099144688),  bigInt(1471811965881636848),  bigInt(1473252190954785008),  bigInt(1474691606230267376),
		bigInt(1476130212618224368),  bigInt(1477568011027263216),  bigInt(1479005002364461296),  bigInt(1480441187535368944),  bigInt(1481876567444013296),
		bigInt(1483311142992902384),  bigInt(1484744915083026928),  bigInt(1486177884613865200),  bigInt(1487610052483385584),  bigInt(1489041419588050416),
		bigInt(1490471986822819056),  bigInt(1491901755081151472),  bigInt(1493330725255011312),  bigInt(1494758898234869488),  bigInt(1496186274909707504),
		bigInt(1497612856167020272),  bigInt(1499038642892820464),  bigInt(1500463635971640560),  bigInt(1501887836286537200),  bigInt(1503311244719094256),
		bigInt(1504733862149424880),  bigInt(1506155689456176880),  bigInt(1507576727516534512),  bigInt(1508996977206221552),  bigInt(1510416439399505904),
		bigInt(1511835114969201392),  bigInt(1513253004786672112),  bigInt(1514670109721834224),  bigInt(1516086430643161328),  bigInt(1517501968417684976),
		bigInt(1518916723911000304),  bigInt(1520330697987267568),  bigInt(1521743891509216496),  bigInt(1523156305338148080),  bigInt(1524567940333939184),
		bigInt(1525978797355044336),  bigInt(1527388877258500336),  bigInt(1528798180899927536),  bigInt(1530206709133535216),  bigInt(1531614462812122352),
		bigInt(1533021442787082480),  bigInt(1534427649908405744),  bigInt(1535833085024682736),  bigInt(1537237748983106800),  bigInt(1538641642629477616),
		bigInt(1540044766808204528),  bigInt(1541447122362308592),  bigInt(1542848710133426672),  bigInt(1544249530961813488),  bigInt(1545649585686345456),
		bigInt(1547048875144524016),  bigInt(1548447400172476912),  bigInt(1549845161604962800),  bigInt(1551242160275374320),  bigInt(1552638397015739376),
		bigInt(1554033872656726256),  bigInt(1555428588027644912),  bigInt(1556822543956451056),  bigInt(1558215741269748208),  bigInt(1559608180792791280),
		bigInt(1560999863349489648),  bigInt(1562390789762408688),  bigInt(1563780960852774896),  bigInt(1565170377440476912),  bigInt(1566559040344069616),
		bigInt(1567946950380775920),  bigInt(1569334108366490864),  bigInt(1570720515115783664),  bigInt(1572106171441900784),  bigInt(1573491078156769008),
		bigInt(1574875236070998000),  bigInt(1576258645993883120),  bigInt(1577641308733408496),  bigInt(1579023225096250352),  bigInt(1580404395887778544),
		bigInt(1581784821912060400),  bigInt(1583164503971862768),  bigInt(1584543442868656112),  bigInt(1585921639402616048),  bigInt(1587299094372626160),
		bigInt(1588675808576281584),  bigInt(1590051782809891312),  bigInt(1591427017868481008),  bigInt(1592801514545795824),  bigInt(1594175273634302704),
		bigInt(1595548295925194224),  bigInt(1596920582208389616),  bigInt(1598292133272539376),  bigInt(1599662949905026544),  bigInt(1601033032891970288),
		bigInt(1602402383018228208),  bigInt(1603771001067398896),  bigInt(1605138887821825008),  bigInt(1606506044062596080),  bigInt(1607872470569550064),
		bigInt(1609238168121277936),  bigInt(1610603137495124464),  bigInt(1611967379467192048),  bigInt(1613330894812342512),  bigInt(1614693684304200688),
		bigInt(1616055748715156208),  bigInt(1617417088816367088),  bigInt(1618777705377761264),  bigInt(1620137599168039664),  bigInt(1621496770954678768),
		bigInt(1622855221503933936),  bigInt(1624212951580840688),  bigInt(1625569961949218032),  bigInt(1626926253371671024),  bigInt(1628281826609593840),
		bigInt(1629636682423170800),  bigInt(1630990821571380464),  bigInt(1632344244811997680),  bigInt(1633696952901595888),  bigInt(1635048946595549680),
		bigInt(1636400226648037872),  bigInt(1637750793812045296),  bigInt(1639100648839365872),  bigInt(1640449792480604656),  bigInt(1641798225485181168),
		bigInt(1643145948601330928),  bigInt(1644492962576108016),  bigInt(1645839268155388656),  bigInt(1647184866083871984),  bigInt(1648529757105084656),
		bigInt(1649873941961380848),  bigInt(1651217421393946864),  bigInt(1652560196142802160),  bigInt(1653902266946802928),  bigInt(1655243634543643376),
		bigInt(1656584299669858800),  bigInt(1657924263060828400),  bigInt(1659263525450776560),  bigInt(1660602087572776688),  bigInt(1661939950158752240),
		bigInt(1663277113939480048),  bigInt(1664613579644592368),  bigInt(1665949348002579184),  bigInt(1667284419740791280),  bigInt(1668618795585441264),
		bigInt(1669952476261607152),  bigInt(1671285462493234416),  bigInt(1672617755003138032),  bigInt(1673949354513005552),  bigInt(1675280261743397872),
		bigInt(1676610477413753840),  bigInt(1677940002242390768),  bigInt(1679268836946507248),  bigInt(1680596982242186224),  bigInt(1681924438844395760),
		bigInt(1683251207466993392),  bigInt(1684577288822726384),  bigInt(1685902683623235568),  bigInt(1687227392579056368),  bigInt(1688551416399622896),
		bigInt(1689874755793267696),  bigInt(1691197411467226608),  bigInt(1692519384127638768),  bigInt(1693840674479550960),  bigInt(1695161283226918128),
		bigInt(1696481211072606448),  bigInt(1697800458718395632),  bigInt(1699119026864981232),  bigInt(1700436916211975920),  bigInt(1701754127457913328),
		bigInt(1703070661300248816),  bigInt(1704386518435362288),  bigInt(1705701699558560496),  bigInt(1707016205364079344),  bigInt(1708330036545085168),
		bigInt(1709643193793678064),  bigInt(1710955677800894192),  bigInt(1712267489256706032),  bigInt(1713578628850027504),  bigInt(1714889097268713200),
		bigInt(1716198895199562736),  bigInt(1717508023328321776),  bigInt(1718816482339684592),  bigInt(1720124272917295856),  bigInt(1721431395743753712),
		bigInt(1722737851500610544),  bigInt(1724043640868375792),  bigInt(1725348764526518768),  bigInt(1726653223153469680),  bigInt(1727957017426621936),
		bigInt(1729260148022335216),  bigInt(1730562615615935728),  bigInt(1731864420881720560),  bigInt(1733165564492958192),  bigInt(1734466047121890800),
		bigInt(1735765869439736816),  bigInt(1737065032116693232),  bigInt(1738363535821936112),  bigInt(1739661381223624688),  bigInt(1740958568988902128),
		bigInt(1742255099783898352),  bigInt(1743550974273731056),  bigInt(1744846193122508784),  bigInt(1746140756993332464),  bigInt(1747434666548297712),
		bigInt(1748727922448496624),  bigInt(1750020525354019824),  bigInt(1751312475923958512),  bigInt(1752603774816407024),  bigInt(1753894422688463856),
		bigInt(1755184420196233712),  bigInt(1756473767994831088),  bigInt(1757762466738380528),  bigInt(1759050517080018928),  bigInt(1760337919671898096),
		bigInt(1761624675165186800),  bigInt(1762910784210071792),  bigInt(1764196247455760880),  bigInt(1765481065550483952),  bigInt(1766765239141495536),
		bigInt(1768048768875076848),  bigInt(1769331655396537072),  bigInt(1770613899350216432),  bigInt(1771895501379486448),  bigInt(1773176462126753520),
		bigInt(1774456782233460208)
	);
	function log() {
		// log10 impl
		var e = exponent.toInt();
		var c = coefficient;
		if(e == -128 || c <= 0) return NAN;
		final e2 = ((63 - Math.clz64(c)) * 77) >> 8;
		// by scaling coefficient by 10**-e_ bring x to 1
		// as close as possible; remember this scale in e
		c <<= bigInt(8);
		while(true) {
			final x = of(c & ~bigInt(255), -e2 & 255);
			c = x.asBigInt();
			if(!(ONE < x)) break;
		}
		e += e2;

		var y = new Dec64(c) + new Dec64(bigInt(-256));
		final yScaled = make(y.coefficient, y.exponent.toInt() + 3);
		final y2 = yScaled.floor().normal();
		final tabIdx = y2.coefficient.toInt().clamp(LOG_TAB_A, LOG_TAB_B);
		final c2 = of(tabIdx, -3);
		var logC2 = new Dec64(LOG_TAB[tabIdx - LOG_TAB_A]);
		y -= c2;
		y /= new Dec64(c2.asBigInt() + (bigInt(1000) * bigInt(256)));

		var s = make(y.coefficient, y.exponent.toInt()); // ???
		var p = s;
		if(logC2.abs() < ONE) {
			s += logC2;
			logC2 = ZERO;
		}
		y = -y;
		for(i in 1...30+1) {
			p *= y;
			final progress = p.fda(of(i + 1, 0), s);
			if(progress == s) break;
			s = progress;
		}

		if(s.isNaN()) return NAN;
		s += logC2;
		return of(e, 0).fma(LOG10, s);
	}

	function pow(exp: Dec64) {
		var coef = abstract;

		if(exp.isZero()) return ONE;

		// Adjust for negative exponent
		if(exp.coefficient < 0) {
			coef = ONE / coef;
			exp = -exp;
		}
		if(coef.isNaN()) return NAN;
		if(coef.isZero()) return ZERO;

		// If the exponent is an integer, then use the squaring method.

		if(exp.coefficient > 0 && exp.exponent == 0) {
			var aux = ONE;
			var n = exp.coefficient;
			if(n <= 1) return coef;
			while(n > 1) {
				if(n & bigInt(1) != 0) aux *= coef;
				coef *= coef;
				n /= bigInt(2);
			}
			return if(n == 1) aux * coef else aux;
		}
		
		// Otherwise do it the hard way.

		return (coef.log() * exp).exp();
	}

	// The seed variables contain the random number generator's state.
	// They can be set by dec64_seed.
	private static var seed0 = E.asBigInt();
	private static var seed1 = TWO_PI.asBigInt();
	static function random() {
		// Return a number between 0 and 1 containing 16 randomy digits.
		// It uses xorshift128+.
		while(true) {
			var s1 = seed0;
			var s0 = seed1;
			s1 ^= s1 << bigInt(23);
			s1 ^= s0 ^ (s0 >> bigInt(5)) ^ (s1 >> bigInt(18));
			seed0 = s0;
			seed1 = s1;
			final mantissa = (s1 + s0) >> bigInt(10);

			// mantissa contains an integer between 0 and 18014398509481983.
			// If it is less than or equal to 9999999999999999 then we are done.

			if(mantissa <= bigInt(9999999999999999)) {
				return make(mantissa, -16);
			} /*else {
				// since bigints don't overflow I think we just reset for now?
				seed0 = E.asBigInt();
				seed1 = TWO_PI.asBigInt();
			}*/
		}
	}

	static function seed(part0: BigInt, part1: BigInt) {
		// Seed the dec64_random function. It takes any 128 bits as the seed value.
		// The seed must contain at least one 1 bit.
		seed0 = part0;
		seed1 = part1;
		if(seed0 | seed1 == 0) {
			seed1 = bigInt(1);
		}
	}

	function rootOf(index: Dec64) {
		trace("Dec64#rootOf(Dec64) does not work properly right now");
		index = index.normal();
		if(isNaN() || index.isZero() || index.coefficient < 0 || index.exponent != 0
		|| (coefficient < 0 && index.coefficient & bigInt(1) == 0)) {
			return NAN;
		}
		if(isZero()) return ZERO;
		if(index == ONE) return abstract;
		if(index == TWO) return sqrt();
		final indexMinusOne = NEG_ONE + index;
		var result = ONE;
		var prosult = NAN;
		while(true) {
			final progress = (
				(result * indexMinusOne) +
				(abstract / result.pow(indexMinusOne))
			) / index;
			if(progress == result) return result;
			if(progress == prosult) return (progress + result) / TWO;
			prosult = result;
			result = progress;
		}
	}

	// TODO: figure out what the fuck is wrong with this
	function sqrt() {
		final coef = coefficient;
		if(!isNaN() && coef >= 0) {
			if(coef == 0) return ZERO;
			var result = abstract;
			for(_ in 0...56) {
				final progress = ((result + (abstract / result).normal()) / TWO).normal();
				trace(progress > of(MAX64, 0));
				trace(abstract, result, (abstract / result).normal(), result + (abstract / result).normal(), progress);
				if(progress == result) return result;
				result = progress;
			}
			trace("didn't converge");
			return result;
		} else {
			return NAN;
		}
	}
}