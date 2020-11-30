package experimental.jsDialect;

enum TypeKind {
	// Basic
	KNull;
	KUndefined;
	KNumber;
	KString;
	KBoolean;

	// Newer
	KBigInt;
	KSymbol;
	
	// Compound
	KObject;
	KFunction;
	KGenerator;

	// Common
	KArray;
	KRegExp;
	//KDate;
	//KError;
	//KProxy;
	//KPromise
	//KAsyncFunction
	//KGeneratorFunction

	// Other
	KOpt(type: TypeKind);
	KUnion(types: Array<TypeKind>); // maybe use Set idk
	KType(path: Array<String>);
	KAny;
}