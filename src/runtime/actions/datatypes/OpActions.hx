package runtime.actions.datatypes;

import types.base._Function;
import types.Value;
import types.Op;

class OpActions extends ValueActions<Op> {
	override function make(_, spec: Value) {
		spec._match(
			at(fn is _Function) => return new Op(fn),
			_ => throw "bad"
		);
	}
}