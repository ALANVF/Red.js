package tokenizer;

enum AnyMonth {
	MMM(mmm: Int);
	Mon(mon: String);
	Month(month: String);
}

enum DateKind {
	YYYYMDD(yyyy: Int, m: AnyMonth, dd: Int);
	DDMYYYY(dd: Int, m: AnyMonth, yyyy: Int);
	DDMYY(dd: Int, m: AnyMonth, yy: Int);
	YYYYDDD(yyyy: Int, ddd: Int);
	YYYYWW(yyyy: Int, ww: Int);
	YYYYWWD(yyyy: Int, ww: Int, d: Int);
	DateT(yyyy: Int, mm: Int, dd: Int);
}

enum TimeKind {
	HM(h: Int, m: Int);
	HMS(h: Int, m: Int, s: Float);
	HHMMSS(hhmmss: Int);
	HHMMSSD(hhmmss: Int, dec: Int);
	HHMM(hhmm: Int);
}

enum Sign {
	Pos;
	Neg;
}

enum ZoneKind {
	ZoneHM15(sign: Sign, hour: Int, min15: Int);
	ZoneHHMM(sign: Sign, hhmm: Int);
	ZoneHour(sign: Sign, hour: Int);
}