package runtime.actions.datatypes;

import types.base.ComparisonOp;
import types.base.CompareResult;
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
#if !macro // ide issue lol
	override function make(_, spec: Value) {
		return cast(spec, Block).values._match(
			at([
				s is Block,
				{name: "get-definition"} is Issue,
				{symbol: {name: name}} is Word
			]) => ifMatch(runtime.natives.Func.parseSpec(s), {doc: doc, params: params, refines: refines, ret: ret},
				new Native(
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

	override function compare(value1: Native, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(other is Native) => op._match(
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