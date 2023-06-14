package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Word;
import types.Value;
import types.Refinement;
import types.Logic;
import types.String;

class RefinementActions extends WordActions<Refinement> {
	override function mold(value: Refinement, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		buffer.appendChar('/'.code);
		return form(value, buffer, arg, part - 1);
	}
}