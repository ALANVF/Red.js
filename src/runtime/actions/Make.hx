package runtime.actions;

import types.Value;
import types.Datatype;

class Make {
	public static function call(type: Value, spec) {
		return type._match(
			at(d is Datatype) => Actions.get(d.kind).make(None, spec),
			_ => Actions.getFor(type).make(Some(type), spec)
		);
	}
}