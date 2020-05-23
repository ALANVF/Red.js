import * as Red from "./red-types";

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

	| {date: Date}
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
	// dates
	// nan and inf (1.#nan and 1.#inf)
	// ' in number literals
	// tags
	// fix %"..." files
	// and more
	comment:     /;.*?$/m,
	name:        /(?:[a-zA-Z_\*=\&\|!?~`]|[\+\-\.](?!\d))(?:[\w\+\-\*=>\&\|!?~`\.\']|<(?!<))*/,
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
	specialWord: /<[<=>]|>[>=]|>>>|[%<](?=[\s()\[\]<>:]|$)|>/,
	time:        /([\+\-]?\d+):(\d+)(?::(\d+(?:\.\d+)?))?/,
	pair:        /([\+\-]?\d+)[xX]([\+\-]?\d+)/,
	tuple:       /(\d+)\.(\d+)\.(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?/
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
	sharp: 35
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
	// ...

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
		return new Red.RawPercent(token.percent);
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
		return new Red.RawFile(token.file);
	}
	else if("email" in token) {
		const [l, r] = token.email.split("@");
		return new Red.RawEmail(l, r);
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
	else if("tag" in token) { // TODO: implement
		throw new Error("unimplemented!");
	}
	else if("binary" in token) { // TODO: implement
		throw new Error("unimplemented!");
	}

	else if("block" in token) {
		return new Red.RawBlock(token.block.map(tokenToRed));
	}
	else if("paren" in token) {
		return new Red.RawParen(token.paren.map(tokenToRed));
	}
	else if("map" in token) { // TODO: implement
		throw new Error("unimplemented!");
	}
	else if("tuple" in token) {
		return new Red.RawTuple(token.tuple);
	}
	else if("pair" in token) {
		return new Red.RawPair(token.pair.x, token.pair.y);
	}

	else if("date" in token) { // TODO: implement
		throw new Error("unimplemented!");
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