package runtime.actions.datatypes;

import runtime.natives.Func;
import types.Value;
import types.Block;
import types.Function;

class FunctionActions extends ValueActions<Function> {
	override function make(_, spec: Value) {
		spec._match(
			at(block is Block) => if(block.length < 2) throw "invalid spec" else {
				Util._match([block.fastPick(0), block.fastPick(1)],
					at([spec2 is Block, body is Block]) => return Func.call(spec2, body),
					_ => throw "invalid spec"
				);
			},
			_ => throw "invalid spec"
		);
	}
}