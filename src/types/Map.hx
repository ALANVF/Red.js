package types;

import types.base.ComparisonOp;

class Map extends Value {
	public final values: Array<Value>;

	public function new(values: Array<Value>) {
		this.values = values;
	}

	public var size(get, never): Int;
	inline function get_size() return values.length;

	public static function preprocessKey(key: Value): Value {
		return key._match(
			at(_ is SetWord) => key,
			at(w is Word | w is LitWord | w is GetWord) => new SetWord(w.symbol),
			at(b is Binary) => b.copy(),
			at(s is types.base._String) => s.copy(),
			_ => key.TYPE_KIND._match(
				at(DMoney
				 | DInteger | DChar | DFloat | DDate | DPercent
				 | DTuple | DPair | DTime | DIssue | DRefinement
				 | DPoint2D | DPoint3D) => key,
				_ => throw "Invalid key value!"
			)
		);
	}

	public function find(key: Value, cmp: ComparisonOp = CEqual): Null<Int> {
		key = preprocessKey(key); // TODO: don't do this if it's not necessary
		return values.findIndexi((k, i) -> i % 2 == 0 && runtime.Actions.compare(k, key, cmp).cond)._match(
			at(-1) => null,
			at(i) => i
		);
	}
	
	public function get(key: Value, cmp: ComparisonOp = CEqual): Null<Value> {
		key = preprocessKey(key); // TODO: don't do this if it's not necessary
		return values.findIndexi((k, i) -> i % 2 == 0 && runtime.Actions.compare(k, key, cmp).cond)._match(
			at(-1) => null,
			at(i) => values[i + 1]
		);
	}
	
	public function set(key: Value, value: Null<Value>, cmp: ComparisonOp = CEqual) {
		key = preprocessKey(key); // TODO: don't do this if it's not necessary
		values.findIndexi((k, i) -> i % 2 == 0 && runtime.Actions.compare(k, key, cmp).cond)._match(
			at(-1) => {
				values.push(key);
				values.push(value);
			},
			at(i) => {
				values[i + 1] = value;
			}
		);
	}
}