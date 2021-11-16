package runtime.actions.datatypes;

import types.Block;
import types.Action;
import types.Value;
import types.Issue;
import types.Word;
import Util.ifMatch;

using Lambda;
using Util;

class ActionActions extends ValueActions<Action> {
	static var MAPPINGS: #if macro haxe.ds.Map<String, ActionFn> #else Dict<String, ActionFn> #end;

	static function __init__() {
		MAPPINGS = [];
	}

	override function make(_, spec: Value) {
		return Util._match(cast(spec, Block).values,
			at([
				s is Block,
				{name: "get-definition"} is Issue,
				{name: name} is Word
			]) => ifMatch(runtime.natives.Func.parseSpec(s), {doc: doc, params: params, refines: refines, ret: ret},
				new Action(
					doc,
					params,
					refines,
					ret,
					if(MAPPINGS.has(name)) {
						MAPPINGS[name];
					} else {
						throw "NYI";
					}
				)
			),
			_ => throw "Match error!"
		);
	}
}