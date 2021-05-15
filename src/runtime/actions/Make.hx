package runtime.actions;

import types.Value;

class Make {
	public static function call(type: Value, spec) {
		return switch type.KIND {
			case KDatatype(d): Actions.get(d.kind).make(None, spec);
			default: Actions.getFor(type).make(Some(type), spec);
		}
	}
}