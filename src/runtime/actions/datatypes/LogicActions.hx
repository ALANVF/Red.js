package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Value;
import types.Logic;
import types.Integer;
import types.Float;
import types.Percent;
import types.None;
import types.String;

class LogicActions extends ValueActions<Logic> {
	override function make(proto: Null<Logic>, spec: Value): Logic {
		return spec._match(
			at(int is Integer) => Logic.fromCond(cast int.int),
			at(float is Float | float is Percent) => Logic.fromCond(cast float.float),
			_ => to(proto, spec)
		);
	}

	override function to(proto: Null<Logic>, spec: Value): Logic {
		return spec._match(
			at(logic is Logic) => logic,
			at(_ is None) => Logic.FALSE,
			_ => Logic.TRUE
		);
	}

	override function form(value: Logic, buffer: String, _, part: Int) {
		final str = value.cond ? "true" : "false";
		buffer.appendLiteral(str);
		return part - str.length;
	}

	override function mold(value: Logic, buffer: String, _, isAll: Bool, _, _, part: Int, _) {
		if(isAll) {
			final str = value.cond ? "#[true]" : "#[false]";
			buffer.appendLiteral(str);
			return part - str.length;
		} else {
			return form(value, buffer, null, part);
		}
	}

	override function compare(value1: Logic, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(logic2 is Logic) => op._match(
				at(CEqual | CFind | CSame
				| CStrictEqual | CNotEqual
				| CSort | CCaseSort) => {
					return cast value1.cond.asInt() - logic2.cond.asInt();
				},
				_ => return IsInvalid
			),
			_ => return IsInvalid
		);
	}


	/*-- Bitwise actions --*/
	
	override function complement(value: Logic): Logic {
		return Logic.fromCond(!value.cond);
	}

	override function and(value1: Logic, value2: Value): Logic {
		return value2._match(
			at(logic2 is Logic) => Logic.fromCond(value1.cond && logic2.cond),
			_ => throw "bad"
		);
	}
	
	override function or(value1: Logic, value2: Value): Logic {
		return value2._match(
			at(logic2 is Logic) => Logic.fromCond(value1.cond || logic2.cond),
			_ => throw "bad"
		);
	}
	
	override function xor(value1: Logic, value2: Value): Logic {
		return value2._match(
			at(logic2 is Logic) => Logic.fromCond(value1.cond != logic2.cond),
			_ => throw "bad"
		);
	}
}