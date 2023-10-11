package runtime.actions.datatypes;

import types.Integer;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Word;
import types.base._AnyWord;
import types.base.Symbol;
import types.base.Context;
import types.Value;
import types.None;
import types.Word;
import types.LitWord;
import types.Refinement;
import types.Issue;
import types.Issue;
import types.Logic;
import types.String;
import types.Datatype;

class WordActions<This: _Word = Word> extends ValueActions<This> {
	private static final thisType: Class<_Word> = null;

	static function __init__() {
		js.Syntax.code("{0}.thisType = {1}", WordActions, Word);
	}

	inline extern overload function makeThis(symbol: Symbol, ?context: Context, ?index: Int): This {
		return js.Syntax.construct(untyped this.constructor.thisType, symbol, context, index);
	}

	inline extern overload function makeThis(word: _Word) {
		return js.Syntax.instanceof(word, untyped this.constructor.thisType)
				? word
				: makeThis(word.symbol, word.context, word.index);
	}


	override function make(proto: Null<This>, spec: Value) {
		return to(proto, spec);
	}

	override function to(proto: Null<This>, spec: Value) {
		return spec._match(
			at(w is _AnyWord) => makeThis(w.symbol, w.context, w.index),
			at(w is Refinement | w is Issue) => throw "NYI",
			//String
			//Char
			at(d is Datatype) => makeThis(Context.GLOBAL.getSymbol(d.name)),
			at(l is Logic) => makeThis(Context.GLOBAL.getSymbol(l.cond ? "true" : "false")),
			_ => throw "bad"
		);
	}

	override function form(value: This, buffer: String, arg: Null<Int>, part: Int) {
		final name = value.symbol.name;
		buffer.appendLiteral(name);
		return part - name.length;
	}

	override function mold(value: This, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		return form(value, buffer, arg, part);
	}

	override function compare(value1: This, value2: Value, op: ComparisonOp): CompareResult {
		if((value2 is Issue && !(value1 is Issue)) || !(value2 is _Word)) {
			return IsInvalid;
		}

		final other = (untyped value2 : _Word);

		op._match(
			at(CEqual | CNotEqual | CFind) => {
				return cast (!value1.equalsWord(other)).asInt();
			},
			at(CStrictEqual) => {
				return cast (
					value1.thisType() != other.thisType()
					|| value1.symbol != other.symbol
				).asInt();
			},
			at(CSame) => {
				return cast (
					value1.symbol != other.symbol
					|| value1.context != other.context
					|| value1.thisType() != other.thisType()
				).asInt();
			},
			at(CStrictEqualWord) => {
				if((value1 is Word && other is LitWord)
				|| (value1 is LitWord && other is Word)) {
					return cast (value1.symbol != other.symbol).asInt();
				} else {
					return cast (
						value1.thisType() != other.thisType()
						|| value1.symbol != other.symbol
					).asInt();
				}
			},
			_ => {
				// TODO: find a better solution for this
				final str1 = value1.symbol.name.toUpperCase();
				final str2 = other.symbol.name.toUpperCase();
				return if(str1 == str2) IsSame
					else if(str1 < str2) IsLess
					else IsMore;
			}
		);
	}


	/*-- Series actions --*/
	
	override function index_q(word: This) {
		if(word.index == -1) {
			return cast None.NONE;
		} else {
			return new Integer(word.index + 1);
		}
	}
}