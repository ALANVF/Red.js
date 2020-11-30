package types;

import types.base.IFunction;
import types.base._Function;
import haxe.ds.Option;

class Op extends Value implements IFunction {
	public var doc(get, set): Option<std.String>;
	function get_doc() return fn.doc;
	function set_doc(v) return fn.doc = v;

	public var args(get, set): _Args;
	function get_args() return fn.args;
	function set_args(v: _Args) return fn.args = v;
	
	public var refines(get, set): _Refines;
	function get_refines(): _Refines return [];
	function set_refines(v: _Refines) return v;
	
	public var retSpec(get, set): Option<Block>;
	function get_retSpec() return fn.retSpec;
	function set_retSpec(v: Option<Block>) return fn.retSpec = v;

	public var arity(get, never): Int;
	function get_arity() return 2;
	
	public final fn: _Function;

	public function new(fn: _Function) {
		if(fn.arity != 2) {
			throw "op! must take 2 arguments";
		} else {
			this.fn = fn;
		}
	}

	public function arityWithRefines(refines: Iterable<std.String>) return 2;
}