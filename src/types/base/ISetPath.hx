package types.base;

interface ISetPath extends IValue {
	function setPath(access: Value, newValue: Value, ?ignoreCase: Bool): Bool;
}