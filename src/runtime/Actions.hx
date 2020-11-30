package runtime;

import types.Value;
import types.Action;
import types.TypeKind;
import runtime.actions.datatypes.*;

using util.NullTools;

class Actions {
	static final ACTIONS = [
		DUnset => new UnsetActions(),
		DNative => new NativeActions()
	];

	public static inline function get(kind) return ACTIONS.get(kind).notNull();

	public static inline function getFor(value: Value) return ACTIONS.get(value.TYPE_KIND).notNull();

	public static function callAction(action: Action, args: Array<Value>, refines: Map<String, Array<Value>>) {
		return switch [action.fn, args] {
			case [AMake(f), [type, spec]]: f(type, spec);
			default:
				throw "NYI";
		}
	}
}