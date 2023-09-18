import types.Word;
import types.TypeKind;
import types.Datatype;

private var _dummy: Datatype;

macro function genDatatypes(entries: Array<haxe.macro.Expr>) {
	final newEntries = [];
	for(entry in entries) switch entry {
		case macro [$name, $kind]: newEntries.push(macro (
			new util.Tuple2(
				types.base.Context.GLOBAL.add($name, _dummy = new types.Datatype($name, $kind)).symbol,
				_dummy
			)
		));
		default: throw "error!";
	}
	return macro $a{newEntries};
}

@:publicFields
class Load {
	@:keep static inline function _DATATYPES_() return genDatatypes(
		["datatype!", DDatatype],
		["unset!", DUnset],
		["none!", DNone],
		["logic!", DLogic],
		["block!", DBlock],
		["paren!", DParen],
		["string!", DString],
		["file!", DFile],
		["url!", DUrl],
		["char!", DChar],
		["integer!", DInteger],
		["float!", DFloat],
		//["symbol!", DSymbol],
		//["context!", DContext],
		["word!", DWord],
		["set-word!", DSetWord],
		["lit-word!", DLitWord],
		["get-word!", DGetWord],
		["refinement!", DRefinement],
		["issue!", DIssue],
		["native!", DNative],
		["action!", DAction],
		["op!", DOp],
		["function!", DFunction],
		["path!", DPath],
		["lit-path!", DLitPath],
		["set-path!", DSetPath],
		["get-path!", DGetPath],
		//["routine!", DRoutine],
		["bitset!", DBitset],
		["point2D!", DPoint2D],
		["point3D!", DPoint3D],
		["object!", DObject],
		["typeset!", DTypeset],
		["error!", DError],
		//["vector!", DVector],
		["hash!", DHash],
		["pair!", DPair],
		["percent!", DPercent],
		["tuple!", DTuple],
		["map!", DMap],
		["binary!", DBinary],
		//["series!", DSeries],
		["time!", DTime],
		["tag!", DTag],
		["email!", DEmail],
		//["handle!", DHandle],
		["date!", DDate],
		//["port!", DPort],
		//["image!", DImage],
		//["event!", DEvent],
		//["closure!", DClosure],
		["money!", DMoney],
		["ref!", DRef]
	);
}