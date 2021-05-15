package runtime.actions.datatypes;

import types.Block;
import types.Action;
import types.Value;
import types.Issue;
import types.Word;
import haxe.ds.Option;
import Util.match;
import Util.extract;

using util.EnumValueTools;
using Lambda;

class ActionActions extends ValueActions {
	public static var MAPPINGS: #if macro haxe.ds.Map<String, ActionFn> #else Dict<String, ActionFn> #end;

	static function __init__() {
		MAPPINGS = [];
	}

	override public function make(_, spec: Value) {
		return extract(spec.as(Block).array(), [
			_.is(Block) => Some(s),
			_.is(Issue) => Some(_.name => "get-definition"),
			_.is(Word) => Some(_.name => name)],
			match(runtime.natives.Func.parseSpec(s), {doc: doc, args: args, refines: refines, ret: ret},
				new Action(
					doc,
					args,
					refines,
					ret,
					if(MAPPINGS.has(name)) {
						MAPPINGS[name];
					} else {
						throw "NYI";
					}
				)
			)
		);
	}
}