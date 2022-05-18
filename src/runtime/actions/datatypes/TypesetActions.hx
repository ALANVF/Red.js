package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
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

	override function compare(value1: Typeset, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(other is Typeset) => op._match(
				at( CEqual
				  | CSame
				  | CFind
				  | CStrictEqual
				  | CNotEqual
				) => {
					final types1 = value1.types;
					final types2 = other.types;
					
					if(types1.length != types2.length) return IsMore;
					for(type in types1) {
						if(!types2.has(type)) {
							return IsMore;
						}
					}
					return IsSame;
				},
				at(CSort | CCaseSort) => {
					return cast js.lib.Math.sign(value1.types.length - other.types.length);
				},
				_ => return IsInvalid
			),
			_ => return IsInvalid
		);
	}
}