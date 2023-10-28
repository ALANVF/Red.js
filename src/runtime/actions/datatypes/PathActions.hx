package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Path;
import types.base._BlockLike;
import types.Path;
import types.Value;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;
import types.Object;
import types.Typeset;

import runtime.actions.Form;
import runtime.actions.Mold;

import runtime.actions.datatypes.ValueActions.invalid;

class PathActions<This: _Path = Path> extends _BlockLikeActions<This> {
	private function makeThis(values: Array<Value>, ?index: Int): This {
		return cast new Path(values, index);
	}

	override function make(proto: Null<This>, spec: Value): This {
		return spec._match(
			at(_ is Integer | _ is Float) => makeThis([]),
			at(b is _BlockLike) => makeThis(b.cloneValues(), 0),
			at(o is Object) => makeThis((cast ObjectActions._reflect(o, Words.BODY)).values),
			//Vector
			_ => invalid()

		);
	}

	override function to(proto: Null<This>, spec: Value) {
		return spec._match(
			at(o is Object) => makeThis((cast ObjectActions._reflect(o, Words.BODY)).values),
			//Vector
			at(s is String) => makeThis(Tokenizer.parse(s.toJs())),
			at(t is Typeset) => makeThis(cast t.types.toArray()),
			at(b is _BlockLike) => makeThis(b.cloneValues(), 0),
			_ => makeThis([spec])
		);
	}

	override function form(value: This, buffer: String, arg: Null<Int>, part: Int) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, false));
		if(cycle) return part;

		var value = value.asSeries();
		Cycles.push(value.values);

		while(value.isNotTail()) {
			part = Form._call(value.value, buffer, arg, part);
			if(arg != null && part <= 0) {
				Cycles.pop();
				return part;
			}
			++value;

			if(value.isNotTail()) {
				buffer.appendChar('/'.code);
				part--;
			}
		}
		Cycles.pop();
		return part;
	}

	override function mold(
		value: This, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, true));
		if(cycle) return part;

		var value = value.asSeries();
		Cycles.push(value.values);

		while(value.isNotTail()) {
			part = Mold._call(value.value, buffer, isOnly, isAll, isFlat, arg, part, 0);
			if(arg != null && part <= 0) {
				Cycles.pop();
				return part;
			}
			++value;

			if(value.isNotTail()) {
				buffer.appendChar('/'.code);
				part--;
			}
		}
		Cycles.pop();
		return part;
	}
}