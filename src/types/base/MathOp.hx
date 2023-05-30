package types.base;

enum abstract MathOp(Int) {
	final OAdd;
	final OSub;
	final OMul;
	final ODiv;
	final ORem;
	// bitwise op!
	final OOr;
	final OAnd;
	final OXor;
	// set op!
	final OUnique;
	final OUnion;
	final OIntersect;
	final OExclude;
	final ODifference;
}