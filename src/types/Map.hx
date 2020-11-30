package types;

class Map extends Value {
	public final keys: Array<Value>;
	public final values: Array<Value>;

	public function new(keys: Array<Value>, values: Array<Value>) {
		this.keys = keys;
		this.values = values;
	}

	//public static function fromIter(iter: KeyValueIterable<Value, Value>) {}

	public static function fromPairs(pairs: Iterable<{k: Value, v: Value}>) {
		return new Map([for(p in pairs) p.k], [for(p in pairs) p.v]);
	}
}