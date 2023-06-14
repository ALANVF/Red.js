package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import runtime.natives.Func;
import types.Value;
import types.Block;
import types.Word;
import types.Function;

import runtime.Words;
import runtime.actions.Mold;

class FunctionActions extends _IFunctionActions<Function> {
	override function make(_, spec: Value) {
		spec._match(
			at(block is Block) => if(block.length < 2) throw "invalid spec" else {
				Util._match([block.fastPick(0), block.fastPick(1)],
					at([spec2 is Block, body is Block]) => return Func.call(spec2, body),
					_ => throw "invalid spec"
				);
			},
			_ => throw "invalid spec"
		);
	}

	override function reflect(value: Function, field: Word): Value {
		return field.symbol._match(
			at(_ == Words.SPEC => true) => value.origSpec,
			at(_ == Words.BODY => true) => value.body,
			at(_ == Words.WORDS => true) => new Block([
				for(sym in value.ctx.symbols) {
					sym is Word ? sym : new Word(sym.symbol, sym.context, sym.index);
				}
			]),
			_ => throw "bad"
		);
	}

	override function form(value: Function, buffer: types.String, arg: Null<Int>, part: Int) {
		buffer.appendLiteral("?function?");
		return part - 10;
	}

	override function mold(
		value: Function, buffer: types.String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		buffer.appendLiteral("func ");
		part = Mold._call(
			value.origSpec, buffer,
			false, isAll, isFlat,
			arg, part - 5,
			indent
		);

		return Mold._call(
			value.body, buffer,
			false, isAll, isFlat,
			arg, part,
			indent
		);
	}

	override function compare(value1: Function, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(other is Function) => op._match(
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
}