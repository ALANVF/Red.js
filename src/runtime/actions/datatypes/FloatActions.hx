package runtime.actions.datatypes;

import types.base.ComparisonOp;
import types.base.CompareResult;
import types.base._Integer;
import types.base._Float;
import types.Value;
import types.Integer;
import types.Float;
import types.Money;
import types.Time;
import types.Percent;

class FloatActions<This: _Float = Float> extends ValueActions<This> {
	private function makeThis(f: StdTypes.Float): This {
		return cast new Float(f);
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
	
	
	/*-- Scalar actions --*/
	
	override function absolute(value: This) {
		return makeThis(Math.abs(value.float));
	}
}