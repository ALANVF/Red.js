package types;

import types.base.IValue;
import types.base.IDatatype;

#if !macro
@:autoBuild(types.ValueBuilder.build())
#end
abstract class Value implements IValue {
	// Can't make get_TYPE_KIND an abstract function due to a macro bug
	
	public var TYPE_KIND(get, never): TypeKind;
	@:pure function get_TYPE_KIND(): TypeKind throw new NotImplementedException();

	public function isTruthy() {
		return true;
	}
	
	public inline function isA(type: IDatatype) {
		return type.matchesTypeOfValue(this);
	}
}