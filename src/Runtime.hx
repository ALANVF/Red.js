import types.TypeKind;
import types.base.Symbol;
import types.Datatype;
import types.base.Context;

@:publicFields
class Runtime {
	static final DATATYPES: Array<Tuple2<Symbol, Datatype>> = Load._DATATYPES_();

	private static function registerDatatypes() {
		js.Syntax.code("", runtime.NativeBuilder.dumbFixForDCE());
		js.Syntax.code("", runtime.ActionBuilder.dumbFixForDCE());
	}
}