package runtime.actions.datatypes;

import types.Block;
import types.Native;
import types.Value;
import types.Issue;
import types.Word;
import haxe.ds.Option;
import Util.match;
import Util.extract;

using util.EnumValueTools;
using types.Helpers;
using Lambda;

class NativeActions extends ValueActions {
	public static var MAPPINGS: #if macro haxe.ds.Map<String, NativeFn> #else Dict<String, NativeFn> #end;

	static function __init__() {
		MAPPINGS = [];
	}

	override public function make(_, spec: Value) {
		return extract(spec.as(Block).array(), [
			_.is(Block) => Some(s),
			_.is(Issue) => Some(_.name => "get-definition"),
			_.is(Word) => Some(_.name => name)],
			match(runtime.natives.Func.parseSpec(s), {doc: doc, args: args, refines: refines, ret: ret},
				new Native(
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