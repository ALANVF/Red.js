package runtime.actions.datatypes;

import types.base.IDatatype;
import types.Value;
import types.Typeset;
import types.Block;
import types.Word;

class TypesetActions extends ValueActions<Typeset> {
	override function make(_, spec: Value) {
		spec._match(
			at(ts is Typeset) => return ts,
			at(b is Block) => {
				return new Typeset([
					for(value in b) value._match(
						at(w is Word) => w.getValue(),
						_ => value
					)._match(
						at(dt is IDatatype) => dt,
						_ => runtime.natives.Type_q.of(value)
					)
				]);
			},
			_ => throw "bad"
		);
	}
}