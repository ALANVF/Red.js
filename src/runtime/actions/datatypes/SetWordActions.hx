package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Word;
import types.base._AnyWord;
import types.Value;
import types.SetWord;
import types.Issue;
import types.Logic;
import types.String;

class SetWordActions extends WordActions<SetWord> {
	override function mold(value: SetWord, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		part = form(value, buffer, arg, part);
		buffer.appendChar(':'.code);
		return part - 1;
	}
}