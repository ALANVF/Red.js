package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Path;
import types.base._Number;
import haxe.ds.Option;
import types.base._ActionOptions;
import types.*;

class ValueActions {
	public function new() {}
	
	public inline function invalid() {
		throw new InvalidAction("Invalid action!");
	}
	
	public function make(type: Option<Value>, spec: Value): Value invalid();
	public function random(value: Value, options: ARandomOptions): Value invalid();
	public function reflect(value: Value, field: Word): Value invalid();
	public function to(type: Value, spec: Value): Value invalid();
	public function form(value: Value, options: AFormOptions): String invalid();
	public function mold(value: Value, options: AMoldOptions): String invalid();
	public function modify(target: Value, field: Word, value: Value, options: AModifyOptions): Value invalid();

	public function evalPath(parent: Value, element: Value, value: Option<Value>, path: _Path, isCase: Bool): Value invalid();
	public function compare(value1: Value, value2: Value, op: ComparisonOp): CompareResult invalid();

	/*-- Scalar actions --*/
	public function absolute(value: Value): Value invalid();
	public function add(value1: Value, value2: Value): Value invalid();
	public function divide(value1: Value, value2: Value): Value invalid();
	public function multiply(value1: Value, value2: Value): Value invalid();
	public function negate(value: Value): Value invalid();
	public function power(number: _Number, exponent: _Number): _Number invalid();
	public function remainder(value1: Value, value2: Value): Value invalid();
	public function round(n: Value, options: ARoundOptions): Value invalid();
	public function subtract(value1: Value, value2: Value): Value invalid();
	public function even_q(value: Value): Logic invalid();
	public function odd_q(value: Value): Logic invalid();
	
	/*-- Bitwise actions --*/
	public function and(value1: Value, value2: Value): Value invalid();
	public function complement(value: Value): Value invalid();
	public function or(value1: Value, value2: Value): Value invalid();
	public function xor(value1: Value, value2: Value): Value invalid();
	
	/*-- Series actions --*/
	public function append(series: Value, value: Value, options: AAppendOptions): Value invalid();
	public function at(series: Value): Value invalid();
	public function back(series: Value): Value invalid();
	public function change(series: Value, value: Value, options: AChangeOptions): Value invalid();
	public function clear(series: Value): Value invalid();
	public function copy(value: Value, options: ACopyOptions): Value invalid();
	public function find(series: Value, value: Value, options: AFindOptions): Value invalid();
	public function head(series: Value): Value invalid();
	public function head_q(series: Value): Logic invalid();
	public function index_q(series: Value): Integer invalid();
	public function insert(series: Value): Value invalid();
	public function length_q(series: Value): Value invalid();
	public function move(origin: Value, target: Value, options: AMoveOptions): Value invalid();
	public function next(series: Value): Value invalid();
	public function pick(series: Value, index: Value): Value invalid();
	public function poke(series: Value, index: Value, value: Value): Value invalid();
	public function put(series: Value, key: Value, value: Value, options: APutOptions): Value invalid();
	public function remove(series: Value, options: ARemoveOptions): Value invalid();
	public function reverse(series: Value, options: AReverseOptions): Value invalid();
	public function select(series: Value, value: Value, options: ASelectOptions): Value invalid();
	public function sort(series: Value, options: ASortOptions): Value invalid();
	public function skip(series: Value, offset: Value): Value invalid();
	public function swap(series1: Value, series2: Value): Value invalid();
	public function tail(series: Value): Value invalid();
	public function tail_q(series: Value): Logic invalid();
	public function take(series: Value, options: ATakeOptions): Value invalid();
	public function trim(series: Value, options: ATrimOptions): Value invalid();
	
	/*-- I/O actions --*/
	public function create(port: Value): Value invalid();
	//public function close(port: Port): Value invalid();
	public function delete(file: Value): Value invalid();
	public function open(port: Value, options: AOpenOptions): Value invalid();
	//public function open_q(port: Port): Logic invalid();
	public function query(target: Value): Value invalid();
	public function read(source: Value, options: AReadOptions): Value invalid();
	public function rename(from: Value, to: Value): Value invalid();
	//public function update(port: Port): Value invalid();
	public function write(destination: Value, data: Value, options: AWriteOptions): Value invalid();
	
	//public function apply(???): ??? invalid();
}