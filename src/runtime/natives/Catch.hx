package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.Value;
import types.Error;
import types.Block;
import types.Word;

@:build(runtime.NativeBuilder.build())
class Catch {
	public static final defaultOptions = Options.defaultFor(NCatchOptions);

	public static function call(block: Block, options: NCatchOptions) {
		try {
			return Do.evalValues(block);
		} catch(e: RedError) {
			if(e.isThrow()) {
				options.name._andOr(nameOpt => {
					e.name._andOr(ename => nameOpt.word._match(
						at(name is Word) => {
							if(name.symbol.equalsSymbol(ename.symbol)) {
								return e.error.arg1;
							} else {
								throw e;
							}
						},
						at(b is Block) => {
							for(v in b) v._match(
								at(name is Word) => {
									if(name.symbol.equalsSymbol(ename.symbol)) {
										return e.error.arg1;
									}
								},
								_ => throw "Invalid type!"
							);
							throw e;
						},
						_ => throw "Invalid type!"
					), {
						throw e;
					});
				}, {
					return e.error.arg1;
				});
			} else {
				throw e;
			}
		}
	}
}