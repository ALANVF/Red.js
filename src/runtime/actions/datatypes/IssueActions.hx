package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Word;
import types.Value;
import types.Issue;
import types.Logic;
import types.String;

class IssueActions extends WordActions<Issue> {
	override function mold(value: Issue, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		buffer.appendChar('#'.code);
		return form(value, buffer, arg, part - 1);
	}

	override function compare(value1: Issue, value2: Value, op: ComparisonOp) {
		if(!(value2 is Issue)) {
			return IsInvalid;
		}
		
		return super.compare(value1, value2, op);
	}
}