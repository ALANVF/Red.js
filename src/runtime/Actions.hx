package runtime;

import types.base.Options;
import types.base._ActionOptions;
import types.base.ComparisonOp;
import types.Value;
import types.Logic;
import types.Action;
import types.TypeKind;
import runtime.actions.datatypes.*;

@:publicFields
class Actions {
	private static final ACTIONS = Dict.of(([
		DUnset => new UnsetActions(),
		DNative => new NativeActions(),
		DAction => new ActionActions(),
		DInteger => new IntegerActions<types.Integer>()
	] : Dict<TypeKind, ValueActions<Value>>));

	static inline function get(kind: TypeKind) {
		return ACTIONS[kind].nonNull();
	}

	static inline function getFor(value: Value) return ACTIONS[value.TYPE_KIND].nonNull();

	static function callAction(action: Action, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		return switch [action.fn, args] {
			case [AMake(f), [type, spec]]: f(type, spec);
			// ...
			case [ACompare(_), _]: throw "this can't be called directly!";
			// ...
			case [AAbsolute(f), [v]]: f(v);
			case [AAdd(f), [v1, v2]]: f(v1, v2);
			// ...
			case [ACopy(f), [v]]: f(v, Options.fromRefines(ACopyOptions, refines));
			// ...
			default: throw "NYI";
		}
	}
	
	static function compare(value1: Value, value2: Value, op: ComparisonOp) {
		final cmp = getFor(value1).compare(value1, value2, op);
		
		if(cmp == IsInvalid &&
			!( op == CEqual
			|| op == CSame
			|| op == CStrictEqual
			|| op == CStrictEqualWord
			|| op == CNotEqual
			|| op == CFind)
		) {
			throw 'Invalid comparison: $value1, $op, $value2';
		}
		
		return Logic.fromCond(switch op {
			case CEqual | CFind | CSame | CStrictEqual | CStrictEqualWord: cmp == IsSame;
			case CNotEqual: cmp != IsSame;
			case CLesser: cmp == IsLess;
			case CLesserEqual: cmp != IsMore;
			case CGreater: cmp == IsMore;
			case CGreaterEqual: cmp != IsLess;
			default: throw "error!";
		});
	}
}