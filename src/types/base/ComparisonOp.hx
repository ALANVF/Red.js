package types.base;

enum abstract ComparisonOp(Int) {
	final CEqual;
	final CNotEqual;
	final CStrictEqual;
	final CLesser;
	final CLesserEqual;
	final CGreater;
	final CGreaterEqual;
	final CSort;
	final CCaseSort;
	final CSame;
	final CStrictEqualWord; // same as CSTRICT_EQUAL, but relaxed type matching for words
	final CFind;
}