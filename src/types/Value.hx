package types;

import types.base.IValue;
import types.base.IDatatype;

#if !macro
@:autoBuild(types.ValueBuilder.build())
#end
abstract class Value implements IValue {
	// Can't make get_KIND and get_TYPE_KIND abstract functions due to a macro bug
	
	public var KIND(get, never): ValueKind;
	function get_KIND(): ValueKind throw new NotImplementedException();

	public var TYPE_KIND(get, never): TypeKind;
	function get_TYPE_KIND(): TypeKind throw new NotImplementedException();

	public function isTruthy() {
		return true;
	}
	
	public inline function isA(type: IDatatype) {
		return type.matchesTypeOfValue(this);
	}
}