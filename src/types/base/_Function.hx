package types.base;

import types.base.IFunction;

abstract class _Function extends Value implements IFunction {
	var _origSpec: Block;
	public var origSpec(get, set): Block;
	function get_origSpec() return _origSpec;
	function set_origSpec(v) return _origSpec = v;

	var _doc: Null<std.String>;
	public var doc(get, set): Null<std.String>;
	function get_doc() return _doc;
	function set_doc(v) return _doc = v;

	var _params: _Params;
	public var params(get, set): _Params;
	function get_params() return _params;
	function set_params(v: _Params) return _params = v;
	
	var _refines: _Refines;
	public var refines(get, set): _Refines;
	function get_refines() return _refines;
	function set_refines(v: _Refines) return _refines = v;

	var _retSpec: Null<Block>;
	public var retSpec(get, set): Null<Block>;
	function get_retSpec() return _retSpec;
	function set_retSpec(v: Null<Block>) return _retSpec = v;

	public var arity(get, never): Int;
	function get_arity() return this._params.length;

	public function new(origSpec: Block, doc: Null<std.String>, params: _Params, refines: _Refines, retSpec: Null<Block>) {
		this.origSpec = origSpec;
		this.doc = doc;
		this.params = params;
		this.refines = refines;
		this.retSpec = retSpec;
	}

	public function arityWithRefines(refines: Iterable<std.String>) {
		var nparams = this.arity;
		
		for(refine in refines) {
			final name = refine.toLowerCase();
			switch this.refines.find(r -> r.name.toLowerCase() == name) {
				case null: throw "Error!";
				case {params: params}: nparams += params.length;
				case _:
			}
		}

		return nparams;
	}

	public function findRefine(w: _Word) {
		return refines.find(ref -> w.symbol.equalsString(ref.name));
	}
}