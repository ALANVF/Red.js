package runtime.natives;

import types.base.ComparisonOp;
import types.base.Options;
import types.base._NativeOptions;
import types.Value;
import types.Block;
import types.Hash;
import types.Word;
import types.Map;
import types.Object;

@:build(runtime.NativeBuilder.build())
class Extend {
	public static final defaultOptions = Options.defaultFor(NExtendOptions);

	public static function call(obj: Value, spec: Value, options: NExtendOptions) {
		final ignoreCase = !options._case;
		final op = options._case ? CStrictEqual : CEqual;

		obj._match(
			at(map is Map) => spec._match(
				at(b is Block | b is Hash) => {
					final length = b.length & ~1 /* make it even */;

					for(i in 0...length) if(i % 2 == 0) {
						map.set(b.fastPick(i), b.fastPick(i + 1));
					}
				},
				at(m is Map) => {
					var i = 0;
					while(i < m.size) {
						map.set(m.values[i], m.values[i + 1], op);
						i += 2;
					}
				},
				_ => throw "Invalid value!"
			),
			at(obj is Object) => {
				throw "NYI!";
			},
			_ => throw "Invalid value!"
		);

		return obj;
	}
}