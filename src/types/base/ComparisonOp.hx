package types.base;

enum ComparisonOp {
	CEqual;
	CNotEqual;
	CStrictEqual;
	CLesser;
	CLesserEqual;
	CGreater;
	CGreaterEqual;
	CSort;
	CCaseSort;
	CSame;
	CStrictEqualWord;							// same as STRICT_EQUAL, but relaxed type matching for words
	CFind;
}