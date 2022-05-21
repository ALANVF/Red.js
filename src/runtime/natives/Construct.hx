package runtime.natives;

import types.base.Options;
import types.base._NativeOptions;
import types.*;

@:build(runtime.NativeBuilder.build())
class Construct {
	public static final defaultOptions = Options.defaultFor(NConstructOptions);

	public static function call(block: Block, options: NConstructOptions) {
		final evalLogic = !options.only;
		final obj = options.with._andOr(
			w => Object.fromObject(w.object),
			new Object()
		);

		var i = block.index;
		final values = block.values;
		final len = values.length;
		while(i < len) {
			values[i]._match(
				at({symbol: {name: field}} is SetWord) => {
					i++;
					
					var value = values[i];
					
					if(evalLogic) value._match(
						at({symbol: {name: name}} is Word) => {
							name.toLowerCase()._match(
								at("true" | "yes" | "on") => value = Logic.TRUE,
								at("false" | "no" | "off") => value = Logic.FALSE,
								_ => {}
							);
						},
						_ => {}
					);

					obj.addOrSet(field, value);
				},
				_ => {}
			);

			i++;
		}

		return obj;
	}
}