package types.base;

interface IValue {
	public var KIND(get, never): ValueKind;
	private function get_KIND(): ValueKind;
	
	public var TYPE_KIND(get, never): TypeKind;
	private function get_TYPE_KIND(): TypeKind;

	public function isTruthy(): Bool;
	public function isA(type: IDatatype): Bool;
}