package types;

import types.base.IDatatype;
import util.Set;

class Typeset extends Value implements IDatatype {
	// TODO: I'm pretty sure R/S actually uses a bitset because `complement` is a thing
	public final types: Set<Datatype>;

	public function new(types: Iterable<IDatatype>) {
		this.types = new Set();

		for(type in types) {
			Util._match(type,
				at(dt is Datatype) => this.types.add(dt),
				at(ts is Typeset) => for(type_ in ts.types) this.types.add(type_),
				_ => {}
			);
		}
	}

	public function matchesTypeOfValue(value: Value) {
		return Lambda.exists(this.types, t -> t.matchesTypeOfValue(value));
	}
}