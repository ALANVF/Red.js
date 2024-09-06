package tokenizer;

import tokenizer.DateMatch;

enum Token {
	TWord(word: String);
	TGetWord(word: String);
	TSetWord(word: String);
	TLitWord(word: String);

	TPath(path: Array<Token>);
	TGetPath(path: Array<Token>);
	TSetPath(path: Array<Token>);
	TLitPath(path: Array<Token>);

	TInteger(int: Int);
	TFloat(float: Float);
	TPercent(percent: Float);
	TMoney(money: String, ?region: String);

	TChar(char: String);
	TString(string: String);
	TRawString(string: String);
	TFile(file: String);
	TEmail(email: String);
	TUrl(url: String);
	TIssue(issue: String);
	TRefinement(refinement: String);
	TTag(tag: String);
	TRef(ref: String);
	TBinary(binary: String, base: Int);

	TBlock(block: Array<Token>);
	TParen(paren: Array<Token>);
	TMap(map: Array<Token>);
	TTuple(tuple: Array<Int>);
	TPair(x: Int, y: Int);
	TPoint2D(x: Float, y: Float);
	TPoint3D(x: Float, y: Float, z: Float);

	TDate(date: DateKind, time: Null<TimeKind>, zone: Null<ZoneKind>);
	TTime(hour: Int, minute: Int, second: Float);
	
	TConstruct(construct: Array<Token>);
}