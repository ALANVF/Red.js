package runtime.actions;

import types.Value;

using util.EnumValueTools;

class Make {
	public static function call(type: Value, spec) {
		return type.KIND.attempt(KDatatype(d),
			Actions.get(d.kind).make(None, spec),
			Actions.getFor(type).make(Some(type), spec)
		);
	}
}