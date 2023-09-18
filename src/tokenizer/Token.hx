package tokenizer;

enum DateToken {
	YearMonthDay(year: Int, month: Int, day: Int);
	YearWeekDay(year: Int, week: Int, day: Int);
	YearDay(year: Int, day: Int);
}

enum DateTimeToken {
	HH_MM_SS(hour: Int, minute: Int, second: Float);
	HHMMSS(time: Float);
}

enum DateZoneToken {
	HH_MM(sign: DateMatch.Sign, hour: Int, minute: Int);
	HHMM(sign: DateMatch.Sign, time: Int);
}

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
	TMoney(money: Float, region: String);

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

	TDate(date: DateToken, time: Null<DateTimeToken>, zone: Null<DateZoneToken>);
	TTime(hour: Int, minute: Int, second: Float);
	
	TConstruct(construct: Array<Token>);
}