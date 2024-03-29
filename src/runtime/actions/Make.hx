package runtime.actions;

import types.Value;
import types.Datatype;

@:build(runtime.ActionBuilder.build())
class Make {
	public static function call(type: Value, spec: Value) {
		return type._match(
			at(d is Datatype) => Actions.get(d.kind).make(null, spec),
			_ => Actions.getFor(type).make(type, spec)
		);
	}
}