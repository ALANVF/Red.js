import * as Red from "./red-types";
import RedUtil from "./runtime/util";
import {Ref} from "./helper-types";


namespace DateMatch {
	type Match = {[key: string]: string | undefined};
	
	export interface YYYYMMMDD extends Match {
		date_yyyymmmdd_yyyy:      string;
		
		date_yyyymmmdd_mmm_m:     string | undefined;
		date_yyyymmmdd_mmm_mon:   string | undefined;
		date_yyyymmmdd_mmm_month: string | undefined;
		
		date_yyyymmmdd_dd:        string;
	}
	
	export interface DDMMMY extends Match {
		date_ddmmmy_dd:         string;
		
		date_ddmmmy_mmm_m:     string | undefined;
		date_ddmmmy_mmm_mon:   string | undefined;
		date_ddmmmy_mmm_month: string | undefined;
		
		date_ddmmmy_yyyy:      string | undefined;
		date_ddmmmy_yy:        string | undefined;
	}
	
	export interface YYYYDDD extends Match {
		date_yyyyddd_yyyy: string;
		date_yyyyddd_ddd:  string;
	}
	
	export interface YYYYW extends Match {
		date_yyyyW_yyyy: string;
		date_yyyyW_ww:   string;
		date_yyyyW_d:    string | undefined;
	}
	
	export interface DateT extends Match {
		dateT_yyyy: string;
		dateT_mm:   string;
		dateT_dd:   string;
	}
	
	export interface HMS extends Match {
		time_hms_hour: string;
		time_hms_min:  string;
		time_hms_sec:  string | undefined;
	}
	
	export interface HHMMSS extends Match {
		time_hhmmss_hhmmss: string;
		time_hhmmss_dec:    string | undefined;
	}
	
	export interface HHMM extends Match {
		time_hhmm: string;
	}
	
	export interface ZoneHM15 extends Match {
		zone_sign:        "+" | "-";
		zone_hm15_hour:   string;
		zone_hm15_min15:  string;
	}
	
	export interface ZoneHHMM extends Match {
		zone_sign: "+" | "-";
		zone_hhmm: string;
	}
	
	export interface ZoneHour extends Match {
		zone_sign: "+" | "-";
		zone_hour: string;
	}
	
	export function isYYYYMMMDD(match: Match): match is YYYYMMMDD {
		return match.date_yyyymmmdd !== undefined;
	}
	
	export function isDDMMMY(match: Match): match is DDMMMY {
		return match.date_ddmmmy !== undefined;
	}
	
	export function isYYYYDDD(match: Match): match is YYYYDDD {
		return match.date_yyyyddd !== undefined;
	}
	
	export function isYYYYW(match: Match): match is YYYYW {
		return match.date_yyyyW !== undefined;
	}
	
	export function isDateT(match: Match): match is DateT {
		return match.dateT !== undefined;
	}
	
	export function isHMS(match: Match): match is HMS {
		return match.time_hms !== undefined;
	}
	
	export function isHHMMSS(match: Match): match is HHMMSS {
		return match.time_hhmmss !== undefined;
	}
	
	export function isHHMM(match: Match): match is HHMM {
		return match.time_hhmm !== undefined;
	}
	
	export function isZoneHM15(match: Match): match is ZoneHM15 {
		return match.zone_hm15 !== undefined;
	}
	
	export function isZoneHHMM(match: Match): match is ZoneHHMM {
		return match.zone_hhmm !== undefined;
	}
	
	export function isZoneHour(match: Match): match is ZoneHour {
		return match.zone_hour !== undefined;
	}
}


type DateToken =
	| {kind: "year-month-day", year: number, month: number, day: number}
	| {kind: "year-week-day",  year: number, week: number, day: number}
	| {kind: "year-day",       year: number, day: number};

type DateTimeToken =
	| {kind: "hh-mm-ss", hour: number, minute: number, second: number}
	| {kind: "hhmmss",   time: number};

type DateZoneToken =
	| {kind: "hh-mm", sign: '+' | '-', hour: number, minute: number}
	| {kind: "hhmm",  sign: '+' | '-', time: number};

type RedToken =
	| {word: string}
	| {getWord: string}
	| {setWord: string}
	| {litWord: string}

	| {path: RedToken[]}
	| {getPath: RedToken[]}
	| {setPath: RedToken[]}
	| {litPath: RedToken[]}

	| {integer: number}
	| {float: number}
	| {percent: number}
	| {money: number, region: string}

	| {char: string}
	| {string: string, multi: boolean}
	| {file: string}
	| {email: string}
	| {url: string}
	| {issue: string}
	| {refinement: string}
	| {tag: string}
	| {binary: string, base: 2 | 16 | 64}

	| {block: RedToken[]}
	| {paren: RedToken[]}
	| {map: RedToken[]}
	| {tuple: number[]}
	| {pair: {x: number, y: number}}

	| {date: DateToken, time?: DateTimeToken, zone?: DateZoneToken}
	| {time: {hour: number, minute: number, second: number}}
	
	| {construct: RedToken[]};

class Reader {
	stream: string;
	pos: number = 0;

	constructor(stream: string) {
		this.stream = stream;
	}

	get eof() {
		return this.pos == this.stream.length;
	}

	peek(len: number = 1): string | null {
		if(this.eof || this.pos + len > this.stream.length) {
			return null;
		} else {
			return this.stream.substr(this.pos, len);
		}
	}

	peekAt(pos: number, len: number = 1): string | null {
		if(this.eof || this.pos + pos + len > this.stream.length) {
			return null;
		} else {
			return this.stream.substr(this.pos + pos, len);
		}
	}

	peekCharAt(pos: number = 0): number | null {
		if(this.eof || this.pos + pos > this.stream.length) {
			return null;
		} else {
			return this.stream.charCodeAt(this.pos + pos);
		}
	}

	next(len: number = 1): string {
		if(this.eof || this.pos + len > this.stream.length) {
			throw new RangeError("error!");
		} else {
			return this.stream.substr((this.pos += len) - len, len);
		}
	}

	matchRx(rx: RegExp, advance: boolean = true): RegExpMatchArray | null {
		const res = this.stream.substr(this.pos).match(rx);
		
		if(res) {
			if(res.index != 0) {
				return null;
			} else if(advance) {
				this.pos += res[0].length;
			}
		}

		return res;
	}

	match(str: string, advance: boolean = true): boolean {
		const res = this.stream.startsWith(str, this.pos);
		if(res && advance) this.pos += str.length;
		return res;
	}
}

const regexRules = {
	// TODO:
	// nan and inf (1.#nan and 1.#inf)
	// ' in number literals
	// fix %"..." files
	// and more
	comment:     /;.*?$/m,
	name:        /(?:[a-zA-Z_\*=\&\|!?~`^]|[\+\-\.](?!\d))(?:[\w\+\-\*=>\&\|!?~`\.\'^]|<(?!<))*/,
	hexa:        /([A-F\d]{2,})h/,
	number:      /[\+\-]?\d+(?:\.\d+)?/,
	integer:     /[\+\-]?\d+(?!\.)/,
	float:       /[\+\-]?(?:\d*\.\d+(?!\.)|\d+\.(?!\d))/,
	money:       /([\+\-]?)([a-zA-Z]{0,3})\$(\d+(?:\.\d+)?)/,
	string:      /\"((?:\^.||[^"\^])*?)\"/,
	file:        /%(?![\s%:;()\[\]])(?:([^\s;"]+)|\"((?:\^"||[^\^"])*?)\")/,
	email:       /[\w\.]+@[\w\.]+/, // not perfect
	url:         /https?:\/\/[^\s]/, // very lazy for now. also apparently a:b is valid
	char:        /#"(\^(?:[A-Z\[\\\]_@\-/~"\^]||\((?:[A-F\d]+|null|back|tab|line|page|esc|del)\))||.)"/i,
	issue:       /#(?!["\/()\[\]{}:;@\s])([^"\/()\[\]{}:;@\s]+)/,
	specialWord: /<[<=>]|>>>|>[>=]|[%<](?=[\s()\[\]<>:]|$)|>/,
	time:        /([\+\-]?\d+):(\d+)(?::(\d+(?:\.\d+)?))?/,
	pair:        /([\+\-]?\d+)[xX]([\+\-]?\d+)/,
	tuple:       /(\d+)\.(\d+)\.(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?/,
	tag:         /<([^=><\[\](){}l^"\s](?:"[^"]*"||'[^']*'||[^>])*)>/,
	date:        /./ // https://doc.red-lang.org/en/datatypes/date.html
};

{
	const anyCase = (str: string) => [...str].map(ch => `[${ch}${ch.toUpperCase()}]`).join("");
	const rule = (str: string) => str.replace(/\s+/gm, "");

	// Basic rules
	const sep = "[/-]";
	const yyyy = "\\d{3,4}";
	const yy = "\\d{2}";
	const m = "1[012]|0?[1-9]";
	const mm = "1[012]|0[1-9]";
	const mon = "jan feb mar apr may jun jul aug sep oct nov dec".split(" ").map(anyCase).join("|");
	const month = "january february march april may june july august september october november december".split(" ").map(anyCase).join("|");
	const d = "[1-7]";
	const dd = "3[01]|[12]\\d|0?[1-9]";
	const ddd = "36[0-6]|3[0-5]\\d|[12]\\d{2}|0\\d[1-9]|0[1-9]\\d";
	const ww = "5[012]|[1-4]\\d|0[1-9]";
	const hour = "\\d{1,2}"
	const min = "\\d{1,2}";
	const ss = "\\d{1,2}";
	const dec = "\\d+";
	const sign = "[+-]";
	const min15 = "\\d{1,2}";
	const hhmm = "\\d{4}";
	const hhmmss = "\\d{6}";

	// Compound rules:
	const sec = rule(`
		${ss}
		(?:
			\\.
			${dec}
		)?
	`);

	const zone = rule(`
		(?<zone_sign> ${sign})
		(?:
			(?<zone_hm15>
				(?<zone_hm15_hour> ${hour})
				:
				(?<zone_hm15_min15> ${min15})
			)
			| (?<zone_hour> ${hour}\\b)
			| (?<zone_hhmm> ${hhmm})
		)
	`);

	const time = rule(`
		(?<time_hms>
			(?<time_hms_hour> ${hour})
			:
			(?<time_hms_min> ${min})
			(?:
				:
				(?<time_hms_sec> ${sec})
			)?
		)
		| (?<time_hhmmss>
			(?<time_hhmmss_hhmmss> ${hhmmss})
			(?:
				\\.
				(?<time_hhmmss_dec> ${dec})
			)?
		)
		| (?<time_hhmm> ${hhmm})
	`);

	const mmm = (outer: string) => rule(`
		  (?<${outer}_mmm_m> ${m})
		| (?<${outer}_mmm_mon> ${mon})
		| (?<${outer}_mmm_month> ${month})
	`);

	const date = rule(`
		(?<date_yyyymmmdd>
			(?<date_yyyymmmdd_yyyy> ${yyyy})
			${sep}
			(?<date_yyyymmmdd_mmm> ${mmm("date_yyyymmmdd")})
			${sep}
			(?<date_yyyymmmdd_dd> ${dd})
		)
		| (?<date_ddmmmy>
			(?<date_ddmmmy_dd> ${dd})
			${sep}
			(?<date_ddmmmy_mmm> ${mmm("date_ddmmmy")})
			${sep}
			(?:
				  (?<date_ddmmmy_yyyy> ${yyyy})
				| (?<date_ddmmmy_yy> ${yy})
			)
		)
		| (?<date_yyyyddd>
			(?<date_yyyyddd_yyyy> ${yyyy})
			-
			(?<date_yyyyddd_ddd> ${ddd})
		)
		| (?<date_yyyyW>
			(?<date_yyyyW_yyyy> ${yyyy})
			-W
			(?<date_yyyyW_ww> ${ww})
			(?:
				-
				(?<date_yyyyW_d> ${d})
			)?
		)
	`);

	const dateT = rule(`
		(?<dateT_yyyy> ${yyyy})
		(?<dateT_mm> ${mm})
		(?<dateT_dd> ${dd})
	`);

	const main = rule(`
		(?:
			  (?<date> ${date})
			| (?<dateT> ${dateT}) (?=T)
		)
		(?:
			[/T]
			(?<time> ${time})
			(?:
				  (?<Z> Z)
				| (?<zone> ${zone})
			)?
		)?
	`);

	regexRules.date = new RegExp(main);
};

const chars = {
	A: 65,
	Z: 90,
	a: 97,
	z: 122,
	zero: 48,
	nine: 57,
	_: 95,
	dot: 46,
	plus: 43,
	dash: 45,
	star: 42,
	equal: 61,
	and: 38,
	or: 124,
	bang: 33,
	ques: 63,
	tilde: 126,
	bquote: 96,
	lt: 60,
	gt: 62,
	space: 32,
	tab: 9,
	nl: 10,
	lparen: 40,
	rparen: 41,
	lbrack: 91,
	rbrack: 93,
	colon: 58,
	sharp: 35,
	caret: 94
};

const checks = {
	name(rdr: Reader): boolean {
		const next = rdr.peek();
		const next1 = rdr.peekAt(1);
		const next2 = rdr.peekAt(2);

		if(next) {
			const nextc = next.charCodeAt(0);
			const next1c = next1 != null ? next1.charCodeAt(0) : 0;
			const next2c = next2 != null ? next2.charCodeAt(0) : 0;

			return (
				(
					(chars.A <= nextc && nextc <= chars.Z)
					|| (chars.a <= nextc && nextc <= chars.z)
					|| nextc == chars._
					|| nextc == chars.star
					|| nextc == chars.equal
					|| nextc == chars.and
					|| nextc == chars.or
					|| nextc == chars.bang
					|| nextc == chars.ques
					|| nextc == chars.tilde
					|| nextc == chars.bquote
					|| nextc == chars.caret
				)
				|| (
					nextc == chars.dot
					&& !(chars.zero <= next1c && next1c <= chars.nine)
				)
				|| (
					(nextc == chars.plus || nextc == chars.dash)
					&& (
						( // TODO: fix this. it doesn't work. supposed to make sure that +.123 doesn't become a word
							next1c == chars.dot
							&& !(chars.zero <= next2c && next2c <= chars.nine)
						)
						|| !(chars.zero <= next1c && next1c <= chars.nine)
					)
				)
			);
		} else {
			return false;
		}
	},

	specialWord(rdr: Reader): boolean {
		switch(rdr.peekCharAt()) {
			case chars.lt: {
				const next = rdr.peekCharAt(1);
				if(next == chars.lt || next == chars.equal || next == chars.gt) {
					const next2 = rdr.peekCharAt(2);
					return (
						next2 == chars.gt
						|| next2 == chars.space
						|| next2 == chars.tab
						|| next2 == chars.nl
						|| next2 == chars.lparen
						|| next2 == chars.rparen
						|| next2 == chars.lbrack
						|| next2 == chars.rbrack
						|| next2 == chars.colon
						|| rdr.pos + 2 == rdr.stream.length
					);
				} else {
					return (
						next == chars.space
						|| next == chars.tab
						|| next == chars.nl
						|| next == chars.lparen
						|| next == chars.rparen
						|| next == chars.lbrack
						|| next == chars.rbrack
						|| next == chars.colon
						|| rdr.pos + 1 == rdr.stream.length
					);
				}
			}

			case chars.gt: {
				const next = rdr.peekCharAt(1);
				if(next == chars.equal || next == chars.gt) {
					const next2 = rdr.peekCharAt(2);
					return (
						next2 == chars.gt
						|| next2 == chars.space
						|| next2 == chars.tab
						|| next2 == chars.nl
						|| next2 == chars.lparen
						|| next2 == chars.rparen
						|| next2 == chars.lbrack
						|| next2 == chars.rbrack
						|| next2 == chars.colon
						|| rdr.pos + 2 == rdr.stream.length
					);
				} else {
					return (
						next == chars.space
						|| next == chars.tab
						|| next == chars.nl
						|| next == chars.lparen
						|| next == chars.rparen
						|| next == chars.lbrack
						|| next == chars.rbrack
						|| next == chars.colon
						|| rdr.pos + 1 == rdr.stream.length
					);
				}
			}

			case 37: { // %
				const next = rdr.peekCharAt(1);
				return (
					next == chars.space
					|| next == chars.tab
					|| next == chars.nl
					|| next == chars.lparen
					|| next == chars.rparen
					|| next == chars.lbrack
					|| next == chars.rbrack
					|| next == chars.colon
					|| rdr.pos + 1 == rdr.stream.length
				);
			}

			default: {
				return false;
			}
		}
	},

	anyName(rdr: Reader): boolean {
		return checks.name(rdr) || checks.specialWord(rdr);
	},

	integer(rdr: Reader): boolean {
		let next = rdr.peekCharAt();
		let offset = 0;

		if(next == chars.plus || next == chars.dash) {
			offset++;
		}

		next = rdr.peekCharAt(offset);

		if(next && chars.zero <= next && next <= chars.nine) {
			while(next && chars.zero <= next && next <= chars.nine) {
				next = rdr.peekCharAt(++offset);
			}

			return next != chars.dot && next != chars.sharp && next != 88 && next != 120; // X, x
		} else {
			return false;
		}
	},

	float(rdr: Reader): boolean {
		let next = rdr.peekCharAt();
		let offset = 0;

		if(next == chars.plus || next == chars.dash) {
			offset++;
		}

		next = rdr.peekCharAt(offset);

		if(next) {
			if(chars.zero <= next && next <= chars.nine) {
				while(next && chars.zero <= next && next <= chars.nine) {
					next = rdr.peekCharAt(++offset);
				}

				if(next == chars.dot) {
					next = rdr.peekCharAt(++offset);

					while(next && chars.zero <= next && next <= chars.nine) {
						next = rdr.peekCharAt(++offset);
					}

					return next != chars.dot;
				}
			} else if(next == chars.dot) {
				next = rdr.peekCharAt(++offset);

				if(next && chars.zero <= next && next <= chars.nine) {
					while(next && chars.zero <= next && next <= chars.nine) {
						next = rdr.peekCharAt(++offset);
					}

					return next != chars.dot;
				}
			}
		}

		return false;
	},

	number(rdr: Reader): boolean {
		return this.integer(rdr) || this.float(rdr);
	},

	block(rdr: Reader): boolean {
		return rdr.peek() == "[";
	},

	paren(rdr: Reader): boolean {
		return rdr.peek() == "(";
	},

	map(rdr: Reader): boolean {
		return rdr.peek(2) == "#(";
	},

	construct(rdr: Reader): boolean {
		return rdr.peek(2) == "#[";
	},
	
	date(rdr: Reader): boolean {
		return rdr.matchRx(/\d+[\-\/T]/, false) != null;
	}
};

const actions = {
	name(rdr: Reader): string {
		const res = rdr.matchRx(regexRules.name);
		if(res) {
			return res[0];
		} else {
			throw new Error("error while parsing name! (debug: 1)");
		}
	},

	specialWord(rdr: Reader): string {
		const res = rdr.matchRx(regexRules.specialWord);
		if(res) {
			return res[0];
		} else {
			throw new Error("Error while parsing word! (debug: 2)");
		}
	},

	anyName(rdr: Reader): string {
		const res = rdr.matchRx(regexRules.name) || rdr.matchRx(regexRules.specialWord);
		if(res) {
			return res[0];
		} else {
			throw new Error("Error while parsing word! (debug: 3)");
		}
	},

	path(rdr: Reader, head: RedToken): RedToken[] {
		const out = [head];
		
		while(rdr.peek() == "/") {
			rdr.next();

			if(checks.paren(rdr)) {
				out.push({paren: actions.paren(rdr)});
			} else if(checks.anyName(rdr)) {
				out.push({word: actions.anyName(rdr)});
			} else if(checks.integer(rdr)) {
				out.push({integer: actions.integer(rdr)});
			} else if(checks.float(rdr)) {
				out.push({float: actions.float(rdr)});
			} else if(rdr.peek() == "'") {
				rdr.next();

				if(checks.anyName(rdr)) {
					out.push({word: actions.anyName(rdr)});
				} else {
					throw new Error("Error while parsing path! (debug: 1)");
				}
			} else if(rdr.peek() == ":") {
				rdr.next();

				if(checks.anyName(rdr)) {
					out.push({getWord: actions.anyName(rdr)});
				} else {
					throw new Error("Error while parsing path! (debug: 2)");
				}
			} else {
				throw new Error("Error while parsing path! (debug: 3)");
			}
		}

		return out;
	},

	integer(rdr: Reader): number { // TODO: remove regex from this
		const res = rdr.matchRx(regexRules.integer);
		if(res) {
			return +res[0];
		} else {
			throw new Error("Error while parsing integer!");
		}
	},

	float(rdr: Reader): number {
		const res = rdr.matchRx(regexRules.float);
		if(res) {
			return +res[0];
		} else {
			throw new Error("Error while parsing float!");
		}
	},

	delim(rdr: Reader, name: string, start: string, stop: string): RedToken[] {
		rdr.next(start.length);

		const out: RedToken[] = [];

		while(rdr.peek() != stop) {
			if(rdr.eof) {
				throw new Error(`Error while parsing ${name}`);
			}

			makeNext(rdr, out);
		}
		
		rdr.next(stop.length);

		return out;
	},

	block(rdr: Reader) {
		return this.delim(rdr, "paren!", "[", "]");
	},
	
	paren(rdr: Reader) {
		return this.delim(rdr, "block!", "(", ")");
	},

	map(rdr: Reader) {
		return this.delim(rdr, "map!", "#(", ")");
	},

	construct(rdr: Reader) {
		return this.delim(rdr, "constructor!", "#[", "]");
	},
	
	date(rdr: Reader) {
		const match = rdr.matchRx(regexRules.date);
		if(match && match.groups) {
			function getMonth(name: string) {
				name = name.toLowerCase();
				return "jan feb mar apr may jun jul aug sep oct nov dec".split(" ").findIndex(month => name.startsWith(month));
			}
			
			const res = match.groups;
			
			let date: DateToken,
				time: DateTimeToken | undefined,
				zone: DateZoneToken | undefined;
			
			let day:   number,
				month: number,
				year:  number;
			
			if(DateMatch.isDDMMMY(res)) {
				day = +res.date_ddmmmy_dd;
				
				if(res.date_ddmmmy_mmm_m !== undefined) {
					month = +res.date_ddmmmy_mmm_m;
				} else if(res.date_ddmmmy_mmm_mon !== undefined) {
					month = getMonth(res.date_ddmmmy_mmm_mon) + 1;
				} else if(res.date_ddmmmy_mmm_month !== undefined) {
					month = getMonth(res.date_ddmmmy_mmm_month) + 1;
				} else {
					throw new Error("Error 1!");
				}
				
				if(res.date_ddmmmy_yyyy !== undefined) {
					year = +res.date_ddmmmy_yyyy;
				} else if(res.date_ddmmmy_yy !== undefined) {
					year = +res.date_ddmmmy_yy;
					year += (year > 50) ? 1900 : 2000;
				} else {
					throw new Error("Error 2!");
				}
				
				date = {kind: "year-month-day", year, month, day};
			} else if(DateMatch.isYYYYMMMDD(res)) {
				day = +res.date_yyyymmmdd_dd;
				
				if(res.date_yyyymmmdd_mmm_m !== undefined) {
					month = +res.date_yyyymmmdd_mmm_m;
				} else if(res.date_yyyymmmdd_mmm_mon !== undefined) {
					month = getMonth(res.date_yyyymmmdd_mmm_mon) + 1;
				} else if(res.date_yyyymmmdd_mmm_month !== undefined) {
					month = getMonth(res.date_yyyymmmdd_mmm_month) + 1;
				} else {
					throw new Error("Error 3!");
				}
				
				if(res.date_yyyymmmdd_yyyy !== undefined) {
					year = +res.date_yyyymmmdd_yyyy;
				} else if(res.date_yyyymmmdd_yy !== undefined) {
					year = +res.date_yyyymmmdd_yy;
					year += (year > 50) ? 1900 : 2000;
				} else {
					throw new Error("Error 4!");
				}
				
				date = {kind: "year-month-day", year, month, day};
			} else if(DateMatch.isYYYYDDD(res)) {
				date = {
					kind: "year-day",
					year: +res.date_yyyyddd_yyyy,
					day:  +res.date_yyyyddd_ddd
				};
			} else if(DateMatch.isYYYYW(res)) {
				date = {
					kind: "year-week-day",
					year: +res.date_yyyyW_yyyy,
					week: +res.date_yyyyW_ww,
					day:  (res.date_yyyyW_d === undefined) ? 1 : +res.date_yyyyW_d
				};
			} else if(DateMatch.isDateT(res)) {
				date = {
					kind:  "year-month-day",
					year:  +res.dateT_yyyy,
					month: +res.dateT_mm,
					day:   +res.dateT_dd
				};
			} else {
				throw new Error("Error 5!");
			}
			
			if(res.time !== undefined) {
				if(DateMatch.isHMS(res)) {
					time = {
						kind:   "hh-mm-ss",
						hour:   +res.time_hms_hour,
						minute: +res.time_hms_min,
						second: (res.time_hms_sec === undefined) ? 0 : +res.time_hms_sec
					};
				} else if(DateMatch.isHHMM(res)) {
					time = {
						kind: "hhmmss",
						time: +res.time_hhmm * 100
					};
				} else if(DateMatch.isHHMMSS(res)) {
					const ms = (res.time_hhmmss_dec === undefined) ? 0 : +`0.${res.time_hhmmss_dec}`;
					
					time = {
						kind: "hhmmss",
						time: +res.time_hhmmss_hhmmss + ms
					};
				} else {
					throw new Error("Error 6!");
				}
			}
			
			if(res.zone !== undefined) {
				if(DateMatch.isZoneHM15(res)) {
					zone = {
						kind:   "hh-mm",
						sign:   res.zone_sign,
						hour:   +res.zone_hm15_hour,
						minute: +res.zone_hm15_min15
					};
				} else if(DateMatch.isZoneHHMM(res)) {
					zone = {
						kind: "hhmm",
						sign: res.zone_sign,
						time: +res.zone_hhmm
					};
				} else if(DateMatch.isZoneHour(res)) {
					zone = {
						kind:   "hh-mm",
						sign:   res.zone_sign,
						hour:   +res.zone_hour,
						minute: 0
					}
				} else {
					throw new Error("Error 7!");
				}
			}
			
			return {date, time, zone};
		} else {
			throw new Error("Error while parsing date!");
		}
	}
};

function makeNext(rdr: Reader, made: RedToken[]) {
	let res: boolean | RegExpMatchArray | null;

	rdr.matchRx(regexRules.comment);

	// all forms of / and //
	if(res = rdr.matchRx(/\/\/?(?=[\s(\[\])]|$)/)) {
		made.push({word: res[0]});
	} else if(res = rdr.matchRx(/:(\/\/?)/)) {
		made.push({getWord: res[1]});
	} else if(res = rdr.matchRx(/'(\/\/?)/)) {
		made.push({litWord: res[1]});
	} else if(res = rdr.matchRx(/(\/\/?):/)) {
		made.push({setWord: res[1]});
	}

	// refinement!
	else if(rdr.match("/")) {
		if(checks.name(rdr)) {
			made.push({refinement: actions.name(rdr)});
		}
		
		// TODO: remove regex from this
		else if(res = rdr.matchRx(regexRules.number)) {
			made.push({refinement: res[0]});
		}

		else {
			throw new Error("Error while parsing refinement!");
		}
	}

	else if(res = rdr.matchRx(regexRules.hexa)) {
		if(!rdr.eof && rdr.matchRx(/[^\s()\[\]{"]/, false)) {
			throw new Error("Error while parsing hexa!");
		}

		made.push({integer: parseInt(res[1], 16)});
	}

	/*
	// email!
	else if(res = rdr.matchRx(regexRules.email)) {
		made.push({email: res[0]});
	}
	*/

	// file!
	else if(res = rdr.matchRx(regexRules.file)) {
		made.push({file: res[1]});
	}

	// url!
	else if(res = rdr.matchRx(regexRules.url)) {
		made.push({url: res[0]});
	}

	/*
	// money!
	else if(res = rdr.matchRx(regexRules.money)) {
		const [, sign, region, amount] = res;
		made.push({money: +(sign + amount), region});
	}
	*/

	// word!, set-word!, path!, and set-path!
	else if(checks.name(rdr)) {
		const word = actions.name(rdr);

		if(rdr.peek() == ":") {
			rdr.next();
			made.push({setWord: word});
		} else if(rdr.peek() == "/") {
			const path: RedToken[] = actions.path(rdr, {word});

			if(rdr.peek() == ":") {
				rdr.next();
				made.push({setPath: path});
			} else {
				made.push({path});
			}
		} else {
			made.push({word});
		}
	}
	
	// special words like <, <<, <=, >, >>, >>>, >= <>, and %
	else if(checks.specialWord(rdr)) {
		const word = actions.specialWord(rdr);

		if(rdr.peek() == ":") {
			rdr.next();
			made.push({setWord: word});
		} else {
			made.push({word});
		}
	}
	
	// get-word! and get-path!
	else if(rdr.match(":")) {
		if(checks.name(rdr)) {
			const word = actions.name(rdr);

			if(rdr.peek() == ":") {
				throw new Error("Error while parsing get-word!/get-path! (debug: 1)");
			} else if(rdr.peek() == "/") {
				const path: RedToken[] = actions.path(rdr, {word});

				if(rdr.peek() == ":") {
					throw new Error("Error while parsing get-word!/get-path! (debug: 2)");
				} else {
					made.push({getPath: path});
				}
			} else {
				made.push({getWord: word});
			}
		}

		else if(checks.specialWord(rdr)) {
			made.push({getWord: actions.specialWord(rdr)});
		}

		else {
			throw new Error("Error while parsing get-word!/get-path! (debug: 3)");
		}
	}

	// lit-word! and lit-path!
	else if(rdr.match("'")) {
		if(checks.name(rdr)) {
			const word = actions.name(rdr);

			if(rdr.peek() == ":") {
				throw new Error("Error while parsing lit-word!/lit-path! (debug: 1)");
			} else if(rdr.peek() == "/") {
				const path: RedToken[] = actions.path(rdr, {word});

				if(rdr.peek() == ":") {
					throw new Error("Error while parsing lit-word!/lit-path! (debug: 2)");
				} else {
					made.push({litPath: path});
				}
			} else {
				made.push({litWord: word});
			}
		}

		else if(checks.specialWord(rdr)) {
			made.push({litWord: actions.specialWord(rdr)});
		}

		else {
			throw new Error("Error while parsing lit-word!/lit-path! (debug: 3)");
		}
	}

	// issue!
	else if(res = rdr.matchRx(regexRules.issue)) {
		made.push({issue: res[1]});
	}

	// pair!
	else if(res = rdr.matchRx(regexRules.pair)) {
		const [, x, y] = res;
		made.push({pair: {x: +x, y: +y}});
	}

	// time!
	else if(res = rdr.matchRx(regexRules.time)) {
		const [, h, m, s = "0"] = res;
		made.push({time: {hour: +h, minute: +m, second: +s}});
	}

	// date!
	else if(checks.date(rdr)) {
		made.push(actions.date(rdr));
	}

	// float! and percent!
	else if(checks.float(rdr)) {
		const float = actions.float(rdr);

		if(rdr.peek() == "%") {
			made.push({percent: float});
			rdr.next();
		} else {
			made.push({float});
		}
	}

	// integer! and percent!
	else if(checks.integer(rdr)) {
		const integer = actions.integer(rdr);

		if(rdr.peek() == "%") {
			made.push({percent: integer});
			rdr.next();
		} else {
			made.push({integer});
		}
	}

	// tuple!
	else if(res = rdr.matchRx(regexRules.tuple)) {
		made.push({tuple: res.slice(1).filter(val => val !== undefined).map(num => +num)});
	}

	// char!
	else if(res = rdr.matchRx(regexRules.char)) {
		made.push({char: res[1]});
	}

	// string!
	else if(res = rdr.matchRx(regexRules.string)) {
		made.push({string: res[1], multi: false});
	}

	// string! (multiline)
	else if(rdr.match("{")) {
		let out = "";
		let next = "";
		let level = 1;

		while(level > 0) {
			if(rdr.eof) {
				throw new Error(`Syntax error: Invalid string! at "${out}"`);
			}

			switch(next = rdr.next()) {
				case "{": {
					out += "{";
					level++;
					break;
				}

				case "}": {
					out += "}";
					level--;
					break;
				}

				case "^": {
					next = rdr.next();

					if(next == "{" || next == "}") {
						out += next;
					} else {
						out += "^" + next;
					}

					break;
				}

				default: {
					out += next;
					break;
				}
			}
		}
		
		made.push({string: out.slice(0, -1), multi: true});
	}
	
	// tag!
	else if(res = rdr.matchRx(regexRules.tag)) {
		made.push({tag: res[1]});
	}

	// binary! (base 2)
	else if(rdr.match("2#{")) {
		let out = "";
		
		for(let _ = 0; _ < 8; _++) { // TODO: this should allow multiples of 8, not just 8
			while(rdr.matchRx(regexRules.comment) || rdr.matchRx(/\s+/m)) {}

			const next = rdr.next();

			if(next == "0" || next == "1") {
				out += next;
			} else {
				throw new Error(`Syntax error: Invalid binary! 2#{${out}}`);
			}
		}

		while(rdr.matchRx(regexRules.comment) || rdr.matchRx(/\s+/m)) {}

		if(rdr.next() != "}") {
			throw new Error("Error while parsing binary2!");
		}

		made.push({binary: out, base: 2});
	}

	// binary! (base 16)
	else if(rdr.match("16#{") || rdr.match("#{")) {
		let out = "";
		
		while(rdr.peek() != "}") {
			if(rdr.eof) {
				throw new Error("Error while parsing binary16!");
			}

			while(rdr.matchRx(regexRules.comment) || rdr.matchRx(/\s+/m)) {}

			const next = rdr.next(2);

			if(next.match(/[a-fA-F\d]{2}/)) {
				out += next;
			} else {
				throw new Error(`Syntax error: Invalid binary! 16#{${out}}`);
			}
		}

		while(rdr.matchRx(regexRules.comment) || rdr.matchRx(/\s+/m)) {}
		
		if(rdr.next() != "}") {
			throw new Error("Error while parsing binary16!");
		}

		made.push({binary: out, base: 16});
	}

	// binary! (base 64)
	else if(rdr.match("64#{")) {
		let out = "";
		
		while(rdr.peek() != "}") {
			if(rdr.eof) {
				throw new Error("Error while parsing binary64!");
			}

			while(rdr.matchRx(regexRules.comment) || rdr.matchRx(/\s+/m)) {}

			const next = rdr.next();

			if(next.match(/[a-zA-Z\d=/+]/)) {
				out += next;
			} else {
				throw new Error(`Syntax error: Invalid binary! 64#{${out}}`);
			}
		}

		while(rdr.matchRx(regexRules.comment) || rdr.matchRx(/\s+/m)) {}
		
		if(rdr.next() != "}") {
			throw new Error("Error while parsing binary64!");
		}

		made.push({binary: out, base: 64});
	}

	// block!
	else if(checks.block(rdr)) {
		made.push({block: actions.block(rdr)});
	}

	// paren!
	else if(checks.paren(rdr)) {
		made.push({paren: actions.paren(rdr)});
	}

	// map!
	else if(checks.map(rdr)) {
		made.push({map: actions.map(rdr)});
	}

	// construction syntax
	else if(checks.construct(rdr)) {
		made.push({construct: actions.construct(rdr)});
	}
	
	// whitespace
	else if(rdr.matchRx(/\s+/m)) {
		// do nothing
	}
	
	else {
		throw new Error(`Syntax error: Invalid token ${rdr.peek()} near ${rdr.stream.slice(rdr.pos, rdr.pos+5)}`);
	}

	rdr.matchRx(regexRules.comment);
}

function tokenToRed(token: RedToken): Red.AnyType {
	if("word" in token) {
		return new Red.RawWord(token.word);
	}
	else if("getWord" in token) {
		return new Red.RawGetWord(token.getWord);
	}
	else if("setWord" in token) {
		return new Red.RawSetWord(token.setWord);
	}
	else if("litWord" in token) {
		return new Red.RawLitWord(token.litWord);
	}

	else if("path" in token) {
		return new Red.RawPath(token.path.map(tokenToRed));
	}
	else if("getPath" in token) {
		return new Red.RawGetPath(token.getPath.map(tokenToRed));
	}
	else if("setPath" in token) {
		return new Red.RawSetPath(token.setPath.map(tokenToRed));
	}
	else if("litPath" in token) {
		return new Red.RawLitPath(token.litPath.map(tokenToRed));
	}

	else if("integer" in token) {
		return new Red.RawInteger(token.integer);
	}
	else if("float" in token) {
		return new Red.RawFloat(token.float);
	}
	else if("percent" in token) {
		return new Red.RawPercent(token.percent / 100);
	}
	else if("money" in token) {
		return new Red.RawMoney(token.money, token.region);
	}

	else if("char" in token) {
		return Red.RawChar.fromRedChar(token.char);
	}
	else if("string" in token) {
		return Red.RawString.fromRedString(token.string, token.multi);
	}
	else if("file" in token) {
		return new Red.RawFile(new Ref(token.file));
	}
	else if("email" in token) {
		return new Red.RawEmail(new Ref(token.email));
	}
	else if("url" in token) { // TODO: implement
		throw new Error("unimplemented!");
	}
	else if("issue" in token) {
		return new Red.RawIssue(token.issue);
	}
	else if("refinement" in token) {
		if(token.refinement.search(/\d/) == 0) {
			return new Red.RawRefinement(new Red.RawInteger(parseInt(token.refinement)));
		} else {
			return new Red.RawRefinement(new Red.RawWord(token.refinement));
		}
	}
	else if("tag" in token) {
		return new Red.RawTag(new Ref(token.tag));
	}
	else if("binary" in token) {
		let bytes: Buffer;

		if(token.base == 2) {
			bytes = Buffer.from(token.binary.match(/.{8}/g)!.map(b => parseInt(b, 2)));
		} else if(token.base == 16) {
			bytes = Buffer.from(token.binary, "hex");
		} else {
			bytes = Buffer.from(token.binary, "base64");
		}

		return new Red.RawBinary(new Ref(bytes));
	}

	else if("block" in token) {
		return new Red.RawBlock(token.block.map(tokenToRed));
	}
	else if("paren" in token) {
		return new Red.RawParen(token.paren.map(tokenToRed));
	}
	else if("map" in token) {
		if(token.map.length % 2 == 0) {
			const pairs: [Red.AnyType, Red.AnyType][] = [];

			for(let i = 0; i < token.map.length; i += 2) {
				const k = tokenToRed(token.map[i]);
				const v = tokenToRed(token.map[i + 1]);

				if(Red.isScalar(k) || Red.isAnyString(k) || k instanceof Red.RawSetWord) {
					pairs.push([k, v]);
				} else if(Red.isAnyWord(k)) {
					pairs.push([new Red.RawSetWord(k.name), v]);
				} else {
					throw new Error(`${Red.typeName(k)} is not allowed here!`);
				}
			}

			return new Red.RawMap(pairs);
		} else {
			throw new Error("Invalid map literal!");
		}
	}
	else if("tuple" in token) {
		return new Red.RawTuple(token.tuple);
	}
	else if("pair" in token) {
		return new Red.RawPair(token.pair.x, token.pair.y);
	}

	else if("date" in token) {
		let date = new Date();
		
		if(token.date.kind == "year-month-day") {
			date.setFullYear(token.date.year, token.date.month - 1, token.date.day);
		} else if(token.date.kind == "year-week-day") {
			date = RedUtil.Dates.weekToDate(token.date.year, token.date.week);
			if(token.date.day > 1) {
				date.setDate(date.getDate() + (token.date.day - 1));
			}
		} else {
			date.setFullYear(token.date.year, 0, token.date.day);
		}
		
		if(token.time !== undefined) {
			if(token.time.kind == "hh-mm-ss") {
				date.setUTCHours(token.time.hour);
				date.setUTCMinutes(token.time.minute);
				date.setUTCSeconds(token.time.second, (token.time.second * 1000) % 1000);
			} else {
				const seconds = token.time.time % 100;
				const minutes = Math.floor(token.time.time / 100) % 100;
				const hours = Math.floor(token.time.time / 10000) % 100;
				
				date.setUTCHours(hours);
				date.setUTCMinutes(minutes);
				date.setUTCSeconds(seconds, 0);
			}
		} else {
			date.setUTCHours(0);
			date.setUTCMinutes(0);
			date.setUTCSeconds(0, 0);
		}
		
		if(token.zone !== undefined) {
			if(token.zone.kind == "hhmm") {
				token.zone = <{kind: "hh-mm", sign: "+" | "-", hour: number, minute: number}><any>{
					kind:    "hh-mm",
					sign:    token.zone.sign,
					hours:   Math.floor(token.zone.time / 100),
					minutes: token.zone.time % 100
				};
			}
			
			if(token.zone.minute < 15) {
				token.zone.minute = 0;
			} else if(token.zone.minute < 30) {
				token.zone.minute = 15;
			} else if(token.zone.minute < 45) {
				token.zone.minute = 30;
			} else if(token.zone.minute < 60) {
				token.zone.minute = 45;
			} else if(token.zone.minute >= 60) {
				token.zone.hour += Math.floor(token.zone.minute / 60);
				token.zone.minute %= 60;
			}
			
			delete token.zone.kind;
			
			return new Red.RawDate(date, token.time !== undefined, <{sign: "+" | "-", hour: number, minute: number}>token.zone);
		} else {
			return new Red.RawDate(date, token.time !== undefined);
		}
	}
	else if("time" in token) {
		return new Red.RawTime(token.time.hour, token.time.minute, token.time.second);
	}

	else if("construct" in token) {
		if(token.construct.length == 1) {
			const [val] = token.construct;

			if("word" in val) {
				switch(val.word.toLowerCase()) {
					case "true":   return Red.RawLogic.true;
					case "false":  return Red.RawLogic.false;
					case "none":
					case "none!":  return Red.RawNone.none;
					case "unset!": return Red.RawUnset.unset;
					default:       Red.todo();
				}
			} else {
				Red.todo();
			}
		} else {
			Red.todo();
		}
	}
	
	else {
		throw new Error("Internal error!");
	}
}

export function tokenize(input: string) {
	const rdr = new Reader(input);
	const made: RedToken[] = [];

	while(!rdr.eof) {
		makeNext(rdr, made);
	}

	return made.map(tokenToRed);
}