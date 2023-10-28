package runtime.actions.datatypes;

import types.base._ActionOptions.ARemoveOptions;
import types.base._ActionOptions.ASelectOptions;
import types.base._ActionOptions.APutOptions;
import types.base._ActionOptions.AFindOptions;
import types.base._ActionOptions.ACopyOptions;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._Block;
import types.base._Path;
import types.Value;
import types.Integer;
import types.Float;
import types.Map;
import types.String;
import types.Word;
import types.SetWord;
import types.None;

import runtime.actions.datatypes.ValueActions.invalid;

class MapActions extends ValueActions<Map> {
	static function serialize(
		map: Map, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		isIndent: Bool, tabs: Int,
		isMold: Bool
	) {
		if(map.size == 0) return part;
		
		final blank = if(isFlat) {
			isIndent = false;
			' '.code;
		} else {
			if(isMold) {
				buffer.appendChar('\n'.code);
				part--;
			}
			'\n'.code;
		}

		final s = map.values;
		var i = 0;
		var tail = s.length;
		Cycles.push(map.values);

		while(i < tail) {
			final value = s[i];
			final next = s[i + 1];
			if(next != null) {
				if(isIndent) part = ObjectActions.doIndent(buffer, tabs, part);
				
				part = Mold._call(value, buffer, isOnly, isAll, isFlat, arg, part, tabs);
				buffer.appendChar(' '.code);
				part--;

				part = Mold._call(next, buffer, isOnly, isAll, isFlat, arg, part, tabs);

				if(isIndent || i + 2 < tail) {
					buffer.appendChar(blank);
					part--;
				}
			}
			if(arg != null && part <= 0) {
				Cycles.pop();
				return part;
			}
			i += 2;
		}
		Cycles.pop();

		return part;
	}

	static function compareEach(map1: Map, map2: Map, op: ComparisonOp) {
		final isSame = map1.values == map2.values;
		if(op == CSame) return isSame ? IsSame : IsLess;
		if(isSame) return IsSame;

		if(Cycles.find(map1.values)) {
			return if(Cycles.find(map2.values)) IsSame else IsLess;
		}

		final size1 = map1.size;
		final size2 = map2.size;

		if(size1 != size2) {
			return op._match(
				at(CEqual | CFind | CStrictEqual | CNotEqual) => IsMore,
				_ => cast (size1 - size2).sign()
			);
		}

		if(size1 == 0) return IsSame;

		var n = 0;
		final table1 = map1.values;
		var res = IsSame;
		
		Cycles.push(table1);
		Cycles.push(map2.values);
		if(op == CStrictEqual) {
			do {
				final key1 = table1[n];
				final value1 = table1[n + 1];
				if(value1 == null) {
					n += 2;
					continue;
				}

				final value2 = map2.get(key1, CStrictEqual);
				res = if(value2 == null) IsSame else Actions.compareValue(value1, value2, op);
				n += 2;
			} while(res == IsSame && n != size1);
		} else {
			do {
				final key1 = table1[n];
				final value1 = table1[n + 1];
				if(value1 == null) {
					n += 2;
					continue;
				}

				final value2 = map2.get(key1, CEqual);
				// TODO: implement this correctly (needs to account for keys of different cases)
				if(value2 != null) res = Actions.compareValue(value1, value2, CEqual);
				else { res = IsMore; break; }
				n += 2;
			} while(res == IsSame && n != size1);
		}
		Cycles.popN(2);
		return IsSame;
	}


	override function make(proto: Null<Map>, spec: Value) {
		return spec._match(
			at(_ is Integer | _ is Float) => new Map([]),
			at(b is _Block) => {
				if(b.length % 2 != 0) invalid();
				final values = b.cloneValues();
				var i = 0; while(i < values.length) {
					values[i] = Map.preprocessKey(values[i]);
					i += 2;
				}
				new Map(values);
			},
			at(m is Map) => copy(m, Copy.defaultOptions),
			_ => invalid()
		);
	}

	override function to(proto: Null<Map>, spec: Value) {
		if(spec is Integer || spec is Float) invalid();
		return make(proto, spec);
	}

	override function form(value: Map, buffer: String, arg: Null<Int>, part: Int) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, false));
		if(cycle) return part;

		return serialize(value, buffer, false, false, false, arg, part, false, 0, false);
	}

	override function mold(
		value: Map, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, true));
		if(cycle) return part;

		buffer.appendLiteral("#(");
		final prev = part - 2;
		part = serialize(value, buffer, false, isAll, isFlat, arg, prev, true, indent + 1, true);
		if(part != prev && indent > 0) part = ObjectActions.doIndent(buffer, indent, part);
		buffer.appendChar(')'.code);
		return part - 1;
	}

	override function evalPath(
		parent: Map, element: Value, value: Null<Value>,
		path: Null<_Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	): Value {
		final table = parent.values;
		final key = parent.find(element, isCase ? CStrictEqual : CEqual);
		if(value != null) {
			if(key == null) {
				parent.set(element, value);
			} else {
				table[key + 1] = value; 
			}
			return value;
		} else {
			if(key == null || table[key + 1] == null) {
				return None.NONE;
			} else {
				return table[key + 1];
			}
		}
	}
	
	override function compare(value1: Map, value2: Value, op: ComparisonOp): CompareResult {
		return value2._match(
			at(m is Map) => op._match(
				at(CEqual | CFind | CSame | CStrictEqual | CNotEqual) => compareEach(value1, m, op),
				at(CSort | CCaseSort) => IsLess,
				_ => IsInvalid
			),
			_ => IsInvalid
		);
	}


	/*-- Series actions --*/

	override function clear(map: Map): Map {
		map.values.resize(0);
		return map;
	}

	override function copy(value: Map, options: ACopyOptions) {
		return new Map(value.values.copy());
	}

	override function find(map: Map, value: Value, options: AFindOptions): Value {
		final op = options.same ? CSame : options._case ? CStrictEqual : CEqual;
		final table = map.values;
		final key = map.find(value, op);
		if(key == null || table[key + 1] == null) {
			return None.NONE;
		} else {
			return table[key]._match(
				at(k is SetWord) => new Word(k.symbol, k.context, k.index),
				at(k) => k
			);
		}
	}

	override function length_q(map: Map) {
		return new Integer(cast map.size / 2);
	}

	override function put(map: Map, key: Value, value: Value, options: APutOptions) {
		map.set(key, value, options._case ? CStrictEqual : CEqual);
		return value;
	}

	override function remove(map: Map, options: ARemoveOptions) {
		final key = options.key?.keyArg ?? invalid();
		final table = map.values;
		final idx = map.find(key, CStrictEqual);
		if(idx != null && table[idx + 1] != null) {
			table[idx + 1] = null;
		}
		return map;
	}

	override function select(map: Map, value: Value, options: ASelectOptions): Value {
		final op = options.same ? CSame : options._case ? CStrictEqual : CEqual;
		return map.get(value, op) ?? cast None.NONE;
	}
}