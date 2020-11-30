package types.base;

interface IDatatype {
	public var KIND(get, never): ValueKind;
	
	public function matchesTypeOfValue(value: Value): Bool;
}