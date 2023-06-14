package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.Block;
import types.Action;
import types.Value;
import types.Issue;
import types.Word;

import runtime.actions.Mold;

import Util.ifMatch;
using Lambda;

class ActionActions extends _IFunctionActions<Action> {
	static var MAPPINGS: #if macro haxe.ds.Map<String, ActionFn> #else Dict<String, ActionFn> #end;

	static function __init__() {
		MAPPINGS = [];
	}
#if !macro // ide issue lol
	override function make(_, spec: Value) {
		return cast(spec, Block).values._match(
			at([
				s is Block,
				{symbol: {name: "get-definition"}} is Issue,
				{symbol: {name: name}} is Word
			]) => ifMatch(runtime.natives.Func.parseSpec(s), {doc: doc, params: params, refines: refines, ret: ret},
				new Action(
					s,
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

	override function form(value: Action, buffer: types.String, arg: Null<Int>, part: Int) {
		buffer.appendLiteral("?action?");
		return part - 8;
	}

	override function mold(
		value: Action, buffer: types.String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		buffer.appendLiteral("make action! [");

		part = Mold._call(
			value.origSpec, buffer,
			isOnly, isAll, isFlat,
			arg, part - 14,
			indent
		);

		buffer.appendChar(']'.code);
		return part - 1;
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