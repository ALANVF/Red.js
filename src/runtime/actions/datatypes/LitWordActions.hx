package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Word;
import types.base._AnyWord;
import types.Value;
import types.LitWord;
import types.Issue;
import types.Logic;
import types.String;

class LitWordActions extends WordActions<LitWord> {
	override function mold(value: LitWord, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		buffer.appendChar("'".code);
		return form(value, buffer, arg, part - 1);
	}
}