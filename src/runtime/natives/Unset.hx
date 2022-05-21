package runtime.natives;

import types.Value;
import types.Block;
import types.Word;

@:build(runtime.NativeBuilder.build())
class Unset {
	public static function call(value: Value): types.Unset {
		value._match(
			at(word is Word) => {
				word.set(types.Unset.UNSET);
			},
			at(block is Block) => {
				for(val in block) val._match(
					at(word is Word) => {
						word.set(types.Unset.UNSET);
						
					},
					_ => continue
				);
			},
			_ => throw "error!"
		);
		
		return types.Unset.UNSET;
	}
}