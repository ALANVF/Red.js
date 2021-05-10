package types;

@:using(types.ValueKind.Helper)
enum ValueKind {
	//KValue(v: Value);
	KDatatype(v: Datatype);
	KUnset(v: Unset);
	KNone(v: None);
	KLogic(v: Logic);
	KBlock(v: Block);
	KParen(v: Paren);
	KString(v: String);
	KFile(v: File);
	KUrl(v: Url);
	KChar(v: Char);
	KInteger(v: Integer);
	KFloat(v: types.Float);
	//KSymbol(v: Symbol);
	//KContext(v: Context);
	KWord(v: Word);
	KSetWord(v: SetWord);
	KLitWord(v: LitWord);
	KGetWord(v: GetWord);
	KRefinement(v: Refinement);
	KIssue(v: Issue);
	KNative(v: Native);
	KAction(v: Action);
	KOp(v: Op);
	KFunction(v: Function);
	KPath(v: Path);
	KLitPath(v: LitPath);
	KSetPath(v: SetPath);
	KGetPath(v: GetPath);
	//KRoutine(v: Routine);
	KBitset(v: Bitset);
	//KPoint(v: Point);
	KObject(v: Object);
	KTypeset(v: Typeset);
	KError(v: Error);
	//KVector(v: Vector);
	KHash(v: Hash);
	KPair(v: Pair);
	KPercent(v: Percent);
	KTuple(v: Tuple);
	KMap(v: Map);
	KBinary(v: Binary);
	//KSeries(v: Series);
	KTime(v: Time);
	KTag(v: Tag);
	KEmail(v: Email);
	//KHandle(v: Handle);
	KDate(v: Date);
	//KPort(v: Port);
	//KImage(v: Image);
	//KEvent(v: Event);
	//KClosure(v: Closure);
	KMoney(v: Money);
	KRef(v: Ref);
}

class Helper {
	public static inline function typeKind(vk: ValueKind): TypeKind {
		return untyped vk.getIndex();
	}
}