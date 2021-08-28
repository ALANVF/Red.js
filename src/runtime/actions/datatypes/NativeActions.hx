package runtime.actions.datatypes;

import types.Block;
import types.Native;
import types.Value;
import types.Issue;
import types.Word;
import Util.ifMatch;

using Lambda;

class NativeActions extends ValueActions<Native> {
	static var MAPPINGS: #if macro haxe.ds.Map<String, NativeFn> #else Dict<String, NativeFn> #end;

	static function __init__() {
		MAPPINGS = [];
	}

	override function make(_, spec: Value) {
		return Util._match(cast(spec, Block).values,
			at([
				s is Block,
				{name: "get-definition"} is Issue,
				{name: name} is Word
			]) => ifMatch(runtime.natives.Func.parseSpec(s), {doc: doc, args: args, refines: refines, ret: ret},
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
			),
			_ => throw "Match error!"
		);
	}
}