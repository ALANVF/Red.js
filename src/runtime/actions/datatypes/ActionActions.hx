package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Block;
import types.Action;
import types.Value;
import types.Issue;
import types.Word;
import Util.ifMatch;

using Lambda;

class ActionActions extends ValueActions<Action> {
	static var MAPPINGS: #if macro haxe.ds.Map<String, ActionFn> #else Dict<String, ActionFn> #end;

	static function __init__() {
		MAPPINGS = [];
	}
#if !macro // ide issue lol
	override function make(_, spec: Value) {
		return cast(spec, Block).values._match(
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

	override function compare(value1: Action, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(other is Action) => op._match(
				at( CEqual
				  | CFind
				  | CSame
				  | CStrictEqual
				  | CNotEqual
				  | CSort
				  | CCaseSort
				) => {
					return value1 == other ? IsSame : IsLess;
				},
				_ => return IsInvalid
			),
			_ => return IsInvalid
		);
	}
#end
}