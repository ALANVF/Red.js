package tokenizer;

enum DateKind {
	YYYYMDD(yyyy: Int, m: Int, dd: Int);
	YYYYDDD(yyyy: Int, ddd: Int);
	YYYYWWD(yyyy: Int, ww: Int, ?d: Int);
}

enum TimeKind {
	HMS(h: Int, m: Int, s: Float);
	HHMMSS(hhmmss: Int, ms: Int);
	HHMM(hhmm: Int);
}

enum abstract Sign(String) from String {
	final Pos = "+";
	final Neg = "-";
}

enum ZoneKind {
	ZoneHM15(sign: Sign, hour: Int, min15: Int);
	ZoneHHMM(sign: Sign, hhmm: Int);
	ZoneHour(sign: Sign, hour: Int);
}

// haxe is fucking stupid and doesn't special-case DynamicAccess like it does for every other type in the stdlib
typedef Match = {
	?date_yyyyW_d: String,
	?time_hhmmss: String,
	?date_yyyyddd_ddd: String,
	?dateT_dd: String,
	?zone_hour: String,
	?date_yyyymmmdd_yyyy: String,
	?date_yyyymmmdd_mmm: String,
	?dateT_yyyy: String,
	?date_yyyyddd_yyyy: String,
	?zone_hhmm: String,
	?time_hms: String,
	?time_hms_min: String,
	?date_yyyyddd: String,
	?zone_sign: String,
	?dateT_mm: String,
	?zone: String,
	?time: String,
	?time_hhmmss_hhmmss: String,
	?date_ddmmmy: String,
	?time_hhmmss_dec: String,
	?dateT: String,
	?zone_hm15_min15: String,
	?date_ddmmmy_yyyy: String,
	?zone_hm15_hour: String,
	?date: String,
	?zone_hm15: String,
	?time_hms_sec: String,
	?date_ddmmmy_mmm: String,
	?Z: String,
	?date_yyyymmmdd_dd: String,
	?date_yyyyW_yyyy: String,
	?time_hhmm: String,
	?date_yyyyW: String,
	?date_ddmmmy_yy: String,
	?date_yyyymmmdd: String,
	?date_yyyyW_ww: String,
	?time_hms_hour: String,
	?date_ddmmmy_dd: String,
	?date_yyyymmmdd_mmm_m: String,
	?date_yyyymmmdd_mmm_mon: String,
	?date_yyyymmmdd_mmm_month: String,
	?date_ddmmmy_mmm_m: String,
	?date_ddmmmy_mmm_mon: String,
	?date_ddmmmy_mmm_month: String
};

function isYYYYMMMDD(match: Match) {
	return match.date_yyyymmmdd != null;
}

function isDDMMMY(match: Match) {
	return match.date_ddmmmy != null;
}

function isYYYYDDD(match: Match) {
	return match.date_yyyyddd != null;
}

function isYYYYW(match: Match) {
	return match.date_yyyyW != null;
}

function isDateT(match: Match) {
	return match.dateT != null;
}

function isHMS(match: Match) {
	return match.time_hms != null;
}

function isHHMMSS(match: Match) {
	return match.time_hhmmss != null;
}

function isHHMM(match: Match) {
	return match.time_hhmm != null;
}

function isZoneHM15(match: Match) {
	return match.zone_hm15 != null;
}

function isZoneHHMM(match: Match) {
	return match.zone_hhmm != null;
}

function isZoneHour(match: Match) {
	return match.zone_hour != null;
}

private final MONTHS = "jan feb mar apr may jun jul aug sep oct nov dec".split(" ");
function getMonth(name: String) {
	name = name.toLowerCase();
	return MONTHS.findIndex(month -> name.startsWith(month));
}