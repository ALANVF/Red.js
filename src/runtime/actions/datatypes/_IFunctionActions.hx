package runtime.actions.datatypes;

import types.None;
import types.base.IFunction;
import types.Value;
import types.Action;
import types.Native;
import types.Function;
import types.JsRoutine;
import types.Op;
import types.Word;
import types.Integer;

import runtime.Words;

class _IFunctionActions<This: IFunction & Value> extends ValueActions<This> {
	override function reflect(value: This, field: Word): Value {
		return field.symbol._match(
			at(_ == Words.SPEC => true) => value.origSpec,
			at(_ == Words.BODY => true) => {
				if(value is Op) value = cast (cast value : Op).fn;
				value._match(
					at(f is Function) => f.body,
					at(n is Native) => new Integer(n.fn.getIndex() + 1),
					at(a is Action) => new Integer(a.fn.getIndex() + 1),
					at(r is JsRoutine) => None.NONE,
					_ => throw "bad"
				);
			},
			at(_ == Words.WORDS => true) => throw "NYI",
			_ => throw "bad"
		);
	}
}