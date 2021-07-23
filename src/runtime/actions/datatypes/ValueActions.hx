package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Path;
import types.base._Number;
import haxe.ds.Option;
import types.base._ActionOptions;
import types.*;

@:publicFields
class ValueActions<This: Value> {
	function new() {}
	
	static inline function invalid() {
		throw new InvalidAction("Invalid action!");
	}
	
	function make(type: Option<This>, spec: Value): Value invalid();
	function random(value: This, options: ARandomOptions): Value invalid();
	function reflect(value: This, field: Word): Value invalid();
	function to(type: Value, spec: Value): Value invalid();
	function form(value: This, options: AFormOptions): String invalid();
	function mold(value: This, options: AMoldOptions): String invalid();
	function modify(target: This, field: Word, value: Value, options: AModifyOptions): Value invalid();

	function evalPath(parent: Value, element: Value, value: Option<Value>, path: _Path, isCase: Bool): Value invalid();
	function compare(value1: This, value2: Value, op: ComparisonOp): CompareResult invalid();

	/*-- Scalar actions --*/
	function absolute(value: This): This invalid();
	function add(value1: This, value2: Value): Value invalid();
	function divide(value1: This, value2: Value): Value invalid();
	function multiply(value1: This, value2: Value): Value invalid();
	function negate(value: This): This invalid();
	function power(number: _Number, exponent: _Number): _Number invalid();
	function remainder(value1: This, value2: Value): Value invalid();
	function round(n: This, options: ARoundOptions): Value invalid();
	function subtract(value1: This, value2: Value): Value invalid();
	function even_q(value: This): Logic invalid();
	function odd_q(value: This): Logic invalid();
	
	/*-- Bitwise actions --*/
	function and(value1: This, value2: Value): Value invalid();
	function complement(value: This): This invalid();
	function or(value1: This, value2: Value): Value invalid();
	function xor(value1: This, value2: Value): Value invalid();
	
	/*-- Series actions --*/
	function append(series: This, value: Value, options: AAppendOptions): Value invalid();
	function at(series: This): Value invalid();
	function back(series: This): Value invalid();
	function change(series: This, value: Value, options: AChangeOptions): Value invalid();
	function clear(series: This): Value invalid();
	function copy(value: This, options: ACopyOptions): Value invalid();
	function find(series: This, value: Value, options: AFindOptions): Value invalid();
	function head(series: This): Value invalid();
	function head_q(series: This): Logic invalid();
	function index_q(series: This): Integer invalid();
	function insert(series: This): Value invalid();
	function length_q(series: This): Value invalid();
	function move(origin: This, target: Value, options: AMoveOptions): Value invalid();
	function next(series: This): Value invalid();
	function pick(series: This, index: Value): Value invalid();
	function poke(series: This, index: Value, value: Value): Value invalid();
	function put(series: This, key: Value, value: Value, options: APutOptions): Value invalid();
	function remove(series: This, options: ARemoveOptions): Value invalid();
	function reverse(series: This, options: AReverseOptions): Value invalid();
	function select(series: This, value: Value, options: ASelectOptions): Value invalid();
	function sort(series: This, options: ASortOptions): Value invalid();
	function skip(series: This, offset: Value): Value invalid();
	function swap(series1: This, series2: Value): Value invalid();
	function tail(series: This): Value invalid();
	function tail_q(series: This): Logic invalid();
	function take(series: This, options: ATakeOptions): Value invalid();
	function trim(series: This, options: ATrimOptions): Value invalid();
	
	/*-- I/O actions --*/
	function create(port: Value): Value invalid();
	//function close(port: Port): Value invalid();
	function delete(file: Value): Value invalid();
	function open(port: Value, options: AOpenOptions): Value invalid();
	//function open_q(port: Port): Logic invalid();
	function query(target: Value): Value invalid();
	function read(source: Value, options: AReadOptions): Value invalid();
	function rename(from: Value, to: Value): Value invalid();
	//function update(port: Port): Value invalid();
	function write(destination: Value, data: Value, options: AWriteOptions): Value invalid();
	
	//function apply(???): ??? invalid();
}