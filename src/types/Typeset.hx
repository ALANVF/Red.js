package types;

import types.base.IDatatype;
import util.Set;

class Typeset extends Value implements IDatatype {
	// TODO: I'm pretty sure R/S actually uses a bitset because `complement` is a thing
	public final types: Set<Datatype>;

	public static inline function of(types: Array<Datatype>) {
		return new Typeset(new Set(types));
	}

	public static function ofAny(types: Iterable<IDatatype>) {
		final res = new Set<Datatype>();

		for(type in types) {
			Util._match(type,
				at(dt is Datatype) => res.add(dt),
				at(ts is Typeset) => for(type_ in ts.types) res.add(type_),
				_ => {}
			);
		}
		
		return new Typeset(res);
	}

	public function new(types: Set<Datatype>) {
		this.types = types;
	}

	public function matchesTypeOfValue(value: Value) {
		return Lambda.exists(this.types, t -> t.matchesTypeOfValue(value));
	}
}