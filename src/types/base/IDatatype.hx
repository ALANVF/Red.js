package types.base;

interface IDatatype {
	public function matchesTypeOfValue(value: Value): Bool;
}