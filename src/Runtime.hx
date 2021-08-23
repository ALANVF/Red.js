import types.Word;
import types.TypeKind;
import types.Datatype;
import types.base.Context;

@:publicFields
class Runtime {
	static final DATATYPES: Array<util.Tuple2<Word, Datatype>> = [];

	private static function registerDatatypes(ctx: Context) {
		js.Syntax.code("void 0", runtime.NativeBuilder.dumbFixForDCE());
		js.Syntax.code("void 0", runtime.ActionBuilder.dumbFixForDCE());
		
		inline function register(name, kind: TypeKind) {
			final datatype = new Datatype(name, kind);
			final word = ctx.add(name, datatype);
			DATATYPES[cast kind] = new util.Tuple2(word, datatype);
		}

		DATATYPES.resize(cast TypeKind.maxValue());

		register("datatype!", DDatatype);
		register("unset!", DUnset);
		register("none!", DNone);
		register("logic!", DLogic);
		register("block!", DBlock);
		register("paren!", DParen);
		register("string!", DString);
		register("file!", DFile);
		register("url!", DUrl);
		register("char!", DChar);
		register("integer!", DInteger);
		register("float!", DFloat);
		//register("symbol!", DSymbol);
		//register("context!", DContext);
		register("word!", DWord);
		register("set-word!", DSetWord);
		register("lit-word!", DLitWord);
		register("get-word!", DGetWord);
		register("refinement!", DRefinement);
		register("issue!", DIssue);
		register("native!", DNative);
		register("action!", DAction);
		register("op!", DOp);
		register("function!", DFunction);
		register("path!", DPath);
		register("lit-path!", DLitPath);
		register("set-path!", DSetPath);
		register("get-path!", DGetPath);
		//register("routine!", DRoutine);
		register("bitset!", DBitset);
		//register("point!", DPoint);
		register("object!", DObject);
		register("typeset!", DTypeset);
		register("error!", DError);
		//register("vector!", DVector);
		register("hash!", DHash);
		register("pair!", DPair);
		register("percent!", DPercent);
		register("tuple!", DTuple);
		register("map!", DMap);
		register("binary!", DBinary);
		//register("series!", DSeries);
		register("time!", DTime);
		register("tag!", DTag);
		register("email!", DEmail);
		//register("handle!", DHandle);
		register("date!", DDate);
		//register("port!", DPort);
		//register("image!", DImage);
		//register("event!", DEvent);
		//register("closure!", DClosure);
		//register("money!", DMoney);
		register("ref!", DRef);
	}
}