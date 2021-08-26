import types.Word;
import types.TypeKind;
import types.Datatype;
import types.base.Context;
import util.Tuple2;

@:publicFields
class Runtime {
	static final DATATYPES: Array<Tuple2<Word, Datatype>> = Load._DATATYPES_();

	private static function registerDatatypes() {
		js.Syntax.code("", runtime.NativeBuilder.dumbFixForDCE());
		js.Syntax.code("", runtime.ActionBuilder.dumbFixForDCE());
	}
}