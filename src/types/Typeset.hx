package types;

import types.base.IDatatype;
import util.Set;

class Typeset extends Value implements IDatatype {
	public final types: Set<Datatype>;

	public function new(types: Iterable<IDatatype>) {
		this.types = new Set();

		for(type in types) {
			switch type.KIND {
				case KDatatype(dt):
					this.types.add(dt);
				case KTypeset(ts):
					for(type_ in ts.types) {
						this.types.add(type_);
					}
				default:
			}
		}
	}

	public function matchesTypeOfValue(value: Value) {
		return Lambda.exists(this.types, t -> t.matchesTypeOfValue(value));
	}
}