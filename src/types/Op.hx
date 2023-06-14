package types;

import types.base.IFunction;
import types.base._Function;
import haxe.ds.Option;

class Op extends Value implements IFunction {
	public var origSpec(get, set): Block;
	function get_origSpec() return fn.origSpec;
	function set_origSpec(v) return fn.origSpec = v;

	public var doc(get, set): Null<std.String>;
	function get_doc() return fn.doc;
	function set_doc(v) return fn.doc = v;

	public var params(get, set): _Params;
	function get_params() return fn.params;
	function set_params(v: _Params) return fn.params = v;
	
	public var refines(get, set): _Refines;
	function get_refines(): _Refines return [];
	function set_refines(v: _Refines) return v;
	
	public var retSpec(get, set): Null<Block>;
	function get_retSpec() return fn.retSpec;
	function set_retSpec(v: Null<Block>) return fn.retSpec = v;

	public var arity(get, never): Int;
	function get_arity() return 2;
	
	public final fn: _Function;

	public function new(fn: _Function) {
		if(fn.arity != 2) {
			throw "op! must take 2 paramuments";
		} else {
			this.fn = fn;
		}
	}

	public function arityWithRefines(refines: Iterable<std.String>) return 2;
}