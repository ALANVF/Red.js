class Cycles {
	static final size = 1000;
	static final cycles: Array<Any> = Array.ofLength(size);
	static var top = 0;
	static final end = size;

	public static function push(value: Any) {
		cycles[top] = value;
		top++;
		if(top == end) {
			reset();
			throw "too deep";
		}
	}

	public static function pop() {
		if(top > 0) {
			cycles[top--] = js.Lib.undefined; // we don't want random stuff to stay in memory
		}
	}

	public static function popN(n: Int) {
		if(top - n < 0) throw "bad";
		cycles.fill(js.Lib.undefined, top, top + n);
		top -= n;
	}

	public static function reset() {
		cycles.fill(js.Lib.undefined, 0, top + 1);
		top = 0;
	}

	public static function find(value: Any) {
		if(top == 0) return false;
		// TODO: determine if Array#includes could be used instead, might incur slowdown when array is large
		for(i in 0...top+1) {
			if(cycles[i] == value) return true;
		}
		return false;
	}

	public static function detect(value: Any, buffer: types.String, part: Int, isMold: Bool) {
		final node: Any = value._match(
			at(o is types.Object) => o.ctx,
			_ => (value : types.base._BlockLike).values
		);
		if(find(node)) {
			var s: String;
			var size: Int;
			if(isMold) {
				value._match(
					at(_ is types.Block | _ is types.Hash) => { s = "[...]"; size = 5; },
					at(_ is types.Paren) => { s = "(...)"; size = 5; },
					at(_ is types.Map) => { s = "#[...]"; size = 6; },
					at(_ is types.Object) => { s = "make object! [...]"; size = 18; },
					at(_ is types.base._Path) => { s = "..."; size = 3; },
					_ => throw "bad"
				);
			} else {
				s = "...";
				size = 3;
			}
			buffer.appendLiteral(s);
			return new Tuple2(part - size, true);
		} else {
			return new Tuple2(part, false);
		}
	}
}