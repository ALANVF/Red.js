package runtime.natives;

import types.Word;
import types.base.Options;
import types.base._NativeOptions;
import types.Value;
import types.Datatype;

@:build(runtime.NativeBuilder.build())
class Type_q {
	public static final defaultOptions = Options.defaultFor(NType_qOptions);

	public static function of(value: Value): Datatype {
		return Runtime.DATATYPES[cast value.TYPE_KIND]._2;
	}

	public static function call(value: Value, options: NType_qOptions): Value {
		final datatype = Runtime.DATATYPES[cast value.TYPE_KIND];
		
		if(options.word) {
			return new Word(datatype._1);
		} else {
			return datatype._2;
		}
	}
}