package types;

class Map extends Value {
	public final keys: Array<Value>;
	public final values: Array<Value>;

	public function new(keys: Array<Value>, values: Array<Value>) {
		this.keys = keys;
		this.values = values;
	}

	public var size(get, never): Int;
	inline function get_size() return keys.length;

	//public static function fromIter(iter: KeyValueIterable<Value, Value>) {}

	public static function fromPairs(pairs: Iterable<{k: Value, v: Value}>) {
		return new Map([for(p in pairs) p.k], [for(p in pairs) p.v]);
	}

	public static function preprocessKey(key: Value): Value {
		return key._match(
			at(_ is SetWord) => key,
			at(w is Word | w is LitWord | w is GetWord) => new SetWord(w.name, w.context, w.offset),
			at(b is Binary) => b.copy(),
			at(s is types.base._String) => s.copy(),
			_ => key.TYPE_KIND._match(
				at(DMoney | DInteger | DChar | DFloat | DDate | DPercent
				 | DTuple | DPair | DTime | DIssue | DRefinement) => key,
				_ => throw "Invalid key value!"
			)
		);
	}

	public function set(key: Value, value: Value, ignoreCase = true) {
		final cmp: types.base.ComparisonOp = ignoreCase ? CStrictEqual : CEqual;

		key = preprocessKey(key); // TODO: don't do this if it's not necessary
		keys.findIndex(k -> runtime.Actions.compare(k, key, cmp).cond)._match(
			at(-1) => {
				keys.push(key);
				values.push(value);
			},
			at(i) => {
				values[i] = value;
			}
		);
	}
}