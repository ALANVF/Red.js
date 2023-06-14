package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Word;
import types.base._AnyWord;
import types.Value;
import types.GetWord;
import types.Issue;
import types.Logic;
import types.String;

class GetWordActions extends WordActions<GetWord> {
	override function mold(value: GetWord, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		buffer.appendChar(':'.code);
		return form(value, buffer, arg, part - 1);
	}
}