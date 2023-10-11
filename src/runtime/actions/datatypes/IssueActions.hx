package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Word;
import types.base.Symbol;
import types.base.Context;
import types.Value;
import types.Issue;
import types.Logic;
import types.String;
import types.Char;

class IssueActions extends WordActions<Issue> {
	static function __init__() {
		js.Syntax.code("{0}.thisType = {1}", IssueActions, Issue);
	}


	override function to(proto: Null<Issue>, spec: Value) {
		return spec._match(
			at(w is _Word) => makeThis(w.symbol, w.context, w.index),
			at(s is String) => {
				final sym = Symbol.make(s.toJs());
				makeThis(sym, Context.GLOBAL, -1);
			},
			at(c is Char) => {
				final sym = Symbol.make(std.String.fromCharCode(c.int));
				makeThis(sym, Context.GLOBAL, -1);
			},
			_ => throw "bad"
		);
	}

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