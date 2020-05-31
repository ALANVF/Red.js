interface Series {
	index:  number;
	length: number;
}

// temporary
interface SeriesOf<T> extends Series {
	pick(i: number): T;
	current(): SeriesOf<T>;
}

export class RawValue {
	isTruthy(): boolean {
		return true;
	}
	
	isa(type: RawDatatype | RawTypeset): boolean {
		if(type instanceof RawDatatype) {
			return this.constructor === type.repr;
		} else {
			return type.types.some(ty => this.isa(ty));
		}
	}
}

export class RawDatatype extends RawValue {
	constructor(
		public name: string,
		public repr: Function
	) {
		super();
	}

	equals(type: RawDatatype): boolean {
		return this.repr === type.repr;
	}
}


/// words
export class RawWord extends RawValue {
	constructor(public name: string) {
		super();
	}

	get word() {
		return this;
	}
}

export class RawLitWord extends RawValue {
	constructor(public name: string) {
		super();
	}

	get word() {
		return new RawWord(this.name);
	}
}

export class RawGetWord extends RawValue {
	constructor(public name: string) {
		super();
	}

	get word() {
		return new RawWord(this.name);
	}
}

export class RawSetWord extends RawValue {
	constructor(public name: string) {
		super();
	}

	get word() {
		return new RawWord(this.name);
	}
}


/// paths
export class RawPath extends RawValue implements Series {
	index: number = 1;
	
	constructor(public path: AnyType[]) {
		super();
	}

	current(): RawPath {
		if(this.index == 1) {
			return this;
		} else {
			return new RawPath(this.path.slice(this.index - 1));
		}
	}

	get length() {
		return this.path.length - (this.index - 1);
	}
}

export class RawLitPath extends RawValue implements Series {
	index: number = 1;
	
	constructor(public path: AnyType[]) {
		super();
	}

	current(): RawLitPath {
		if(this.index == 1) {
			return this;
		} else {
			return new RawLitPath(this.path.slice(this.index - 1));
		}
	}

	get length() {
		return this.path.length - (this.index - 1);
	}
}

export class RawGetPath extends RawValue implements Series {
	index: number = 1;
	
	constructor(public path: AnyType[]) {
		super();
	}

	current(): RawGetPath {
		if(this.index == 1) {
			return this;
		} else {
			return new RawGetPath(this.path.slice(this.index - 1));
		}
	}

	get length() {
		return this.path.length - (this.index - 1);
	}
}

export class RawSetPath extends RawValue implements Series {
	index: number = 1;
	
	constructor(public path: AnyType[]) {
		super();
	}

	current(): RawSetPath {
		if(this.index == 1) {
			return this;
		} else {
			return new RawSetPath(this.path.slice(this.index - 1));
		}
	}

	get length() {
		return this.path.length - (this.index - 1);
	}
}


/// other words
export class RawRefinement extends RawValue {
	constructor(public name: RawWord|RawInteger) {
		super();
	}

	get word() {
		if(this.name instanceof RawWord) {
			return this.name;
		} else {
			throw new Error("error");
		}
	}
}

export class RawIssue extends RawValue {
	constructor(public value: string) {
		super();
	}
}


/// scalars
export class RawInteger extends RawValue {
	#_1 = undefined; // fix for dumb union bug
	
	constructor(public value: number) {
		super();

		if(value % 1 != 0) {
			throw new TypeError("Internal error: Expected an integer but got a float instead!");
		}
	}
}

export class RawFloat extends RawValue {
	#_2 = undefined; // fix for dumb union bug
	
	constructor(public value: number) {
		super();
	}
}

export class RawMoney extends RawValue {
	constructor(
		public value:  number,
		public region: string = ""
	) {
		super();
	}
}

export class RawPercent extends RawValue {
	#_3 = undefined; // fix for dumb union bug
	
	constructor(public value: number) {
		super();
	}
}

export class RawChar extends RawValue {
	constructor(public char: number) {
		super();
	}

	static fromJsChar(char: string) {
		if(char.length != 0) {
			return new RawChar(char.charCodeAt(0));
		} else {
			throw new Error(`Invalid char! literal #""!`);
		}
	}

	static fromRedChar(char: string) {
		if(char[0] == "^") {
			const esc = char.slice(1).toUpperCase();
			switch(esc) {
				case "\"": return new RawChar(34);
				case "^":  return new RawChar(94);
				case "\\": return new RawChar(28);
				case "]":  return new RawChar(29);
				case "_":  return new RawChar(31);

				case "@": case "(NULL)": return new RawChar(0);
				          case "(BACK)": return new RawChar(8);
				case "-": case "(TAB)":  return new RawChar(9);
				case "/": case "(LINE)": return new RawChar(10);
				          case "(PAGE)": return new RawChar(12);
				case "[": case "(ESC)":  return new RawChar(27);
				case "~": case "(DEL)":  return new RawChar(127);

				default: {
					if("A" <= esc && esc <= "Z") {
						return new RawChar(esc.charCodeAt(0) - 64);
					} else if(esc.match(/^\(([A-F\d]+)\)$/i)) {
						return new RawChar(parseInt(RegExp.$1, 16));
					} else {
						throw new Error(`Invalid char! literal #"^${esc}"!`);
					}
				}
			}
		} else if(char.length != 0) {
			return new RawChar(char.charCodeAt(0));
		} else {
			throw new Error(`Invalid char! literal #""!`);
		}
	}

	toJsChar() {
		return String.fromCharCode(this.char);
	}

	toRedChar() {
		switch(this.char) {
			case 34:  return "^\"";
			case 94:  return "^^";
			case 28:  return "^\\";
			case 29:  return "^]";
			case 31:  return "^_";

			case 0:   return "^@";
			case 8:   return "^(back)";
			case 9:   return "^-";
			case 10:  return "^/";
			case 12:  return "^(page)";
			case 27:  return "^[";
			case 127: return "^~";

			case 30: return "^(1E)";

			default: {
				if(1 <= this.char && this.char <= 26) {
					return "^" + String.fromCharCode(this.char + 64);
				} else {
					return String.fromCharCode(this.char);
				}
			}
		}
	}

	get lowerChar() {
		if(97 <= this.char && this.char <= 122) {
			return this.char - 32;
		} else {
			return this.char;
		}
	}
}

export class RawLogic extends RawValue {
	static readonly true = new RawLogic(true);
	static readonly false = new RawLogic(false);

	constructor(public cond: boolean) {
		super();
	}

	static from(cond: boolean): RawLogic {
		return cond ? RawLogic.true : RawLogic.false;
	}

	isTruthy(): boolean {
		return this.cond;
	}
}

export class RawNone extends RawValue {
	static readonly none = new RawNone();

	isTruthy(): boolean {
		return false;
	}
}


/// series types
export class RawString extends RawValue implements Series, SeriesOf<RawChar> {
	index: number = 1;

	constructor(
		public values:    RawChar[],
		public multiline: boolean = false
	) {
		super();
	}

	static fromJsString(
		value:     string,
		multiline: boolean = false
	) {
		return new RawString([...value].map(c => RawChar.fromJsChar(c)), multiline);
	}

	static fromRedString(
		value:     string,
		multiline: boolean = false
	) {
		const out = [];
		const redEscapeChar = /\^(?:[A-Z\[\\\]_@\-\/~"\^]|\((?:null|back|tab|line|page|esc|del|[A-F\d]+)\))/i;

		while(value.length != 0) {
			const m = value.match(redEscapeChar);
			if(m != null && m.index == 0) {
				out.push(RawChar.fromRedChar(m[0]));
				value = value.slice(m[0].length);
			} else {
				out.push(new RawChar(value.charCodeAt(0)));
				value = value.slice(1);
			}
		}

		return new RawString(out, multiline);
	}

	toJsString() {
		return this.values.slice(this.index - 1).map(char => char.toJsChar()).join("");
	}

	toRedString() {
		return this.values.slice(this.index - 1).map(char => char.toRedChar()).join("");
	}

	pick(i: number) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return this.values[(this.index - 1) + (i - 1)];
	}

	current(): RawString {
		if(this.index == 1) {
			return this;
		} else {
			return new RawString(this.values.slice(this.index - 1));
		}
	}

	get length() {
		return this.values.length - (this.index - 1);
	}
}

export class RawParen extends RawValue implements Series {
	index: number = 1;
	
	constructor(public values: AnyType[]) {
		super();
	}

	pick(i: number) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return this.values[(this.index - 1) + (i - 1)];
	}

	current(): RawParen {
		if(this.index == 1) {
			return this;
		} else {
			return new RawParen(this.values.slice(this.index - 1));
		}
	}

	get length() {
		return this.values.length - (this.index - 1);
	}
}

export class RawBlock extends RawValue implements Series, SeriesOf<AnyType> {
	index: number = 1;

	constructor(public values: AnyType[]) {
		super();
	}

	pick(i: number) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return this.values[(this.index - 1) + (i - 1)];
	}

	current(): RawBlock {
		if(this.index == 1) {
			return this;
		} else {
			return new RawBlock(this.values.slice(this.index - 1));
		}
	}

	get length() {
		return this.values.length - (this.index - 1);
	}
}


/// series-like types
export class RawBinary extends RawValue implements Series, SeriesOf<number> {
	index: number = 1;
	
	constructor(public bytes: Buffer) {
		super();
	}

	pick(i: number) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return this.bytes[(this.index - 1) + (i - 1)];
	}

	current(): RawBinary {
		if(this.index == 1) {
			return this;
		} else {
			return new RawBinary(this.bytes.subarray(this.index - 1));
		}
	}

	get length() {
		return this.bytes.length - (this.index - 1);
	}
}

export class RawBitset extends RawValue {
	// https://github.com/red/red/blob/master/runtime/datatypes/bitset.reds
	// https://github.com/rebol/rebol/blob/master/src/core/t-bitset.c#L202
	
	bytes:   bigint;
	negated: boolean;
	
	constructor(
		bytes:   number[],
		negated: boolean
	) {
		super();

		this.bytes = BigInt(bytes.map(byte => {
			if(byte % 1 == 0 && byte > -1) {
				return 1 << (7 - (byte & 7));
			} else {
				throw new Error("error!");
			}
		}).reduce((a, b) => a | b, 0));
		
		this.negated = negated;
	}

	hasBit(
		byte:    number,
		_noCase: boolean = false // ignore noCase for now
	): boolean {
		if(byte % 1 == 0 && byte > -1) {
			return ((1n << (7n - (BigInt(byte) & 7n)) & this.bytes) != 0n) != this.negated;
		} else {
			throw new Error("error!");
		}
	}

	setBit(
		byte:   number,
		status: boolean
	) {
		if(byte % 1 == 0 && byte > -1) {
			const bit = 1n << (7n - (BigInt(byte) & 7n));
			
			if(this.negated == status) {
				this.bytes &= ~bit;
			} else {
				this.bytes |= bit;
			}
		} else {
			throw new Error("error!");
		}
	}
}

export class RawHash extends RawValue implements Series, SeriesOf<AnyType> {
	index: number = 1;
	
	constructor(public values: AnyType[]) {
		super();
	}

	pick(i: number) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return this.values[(this.index - 1) + (i - 1)];
	}

	current(): RawHash {
		if(this.index == 1) {
			return this;
		} else {
			return new RawHash(this.values.slice(this.index - 1));
		}
	}

	get length() {
		return this.values.length - (this.index - 1);
	}
}

export class RawMap extends RawValue {
	keys:   AnyType[];
	values: AnyType[];

	constructor(pairs: [AnyType, AnyType][]) {
		super();

		this.keys = [];
		this.values = [];

		for(const [key, val] of pairs) {
			this.keys.push(key);
			this.values.push(val);
		}
	}
}

export class RawFile extends RawValue implements Series {
	index: number = 1;

	constructor(public name: string) {
		super();
	}

	get length() {
		return this.name.length - (this.index - 1);
	}
}

export class RawTag extends RawValue implements Series {
	index: number = 1;
	
	constructor(public tag: string) {
		super();
	}

	get length() {
		return this.tag.length - (this.index - 1);
	}
}

export class RawUrl extends RawValue implements Series {
	index: number = 1;
	
	constructor(public url: string) {
		super();
	}

	get length() {
		return this.url.length - (this.index - 1);
	}
}

type Vector = (RawInteger[] | RawFloat[] | RawChar[] | RawPercent[]) & unknown[]; // incomplete hack for dumb union bug
export class RawVector extends RawValue implements Series, SeriesOf<RawInteger|RawFloat|RawChar|RawPercent> {
	index: number = 1;

	constructor(public values: Vector) {
		super();
	}

	static isInteger(values: Vector): values is RawInteger[] {
		return values.every((v: any) => v instanceof RawInteger);
	}

	static isDecimal(values: Vector): values is RawFloat[] {
		return values.every((v: any) => v instanceof RawFloat);
	}

	static isChar(values: Vector): values is RawChar[] {
		return values.every((v: any) => v instanceof RawChar);
	}

	static isPercent(values: Vector): values is RawPercent[] {
		return values.every((v: any) => v instanceof RawPercent);
	}

	pick(i: number) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return this.values[(this.index - 1) + (i - 1)];
	}

	current(): RawVector {
		if(this.index == 1) {
			return this;
		} else {
			return new RawVector(this.values.slice(this.index - 1));
		}
	}

	get length() {
		return this.values.length - (this.index - 1);
	}
}


/// simple compound types
export class RawEmail extends RawValue implements Series {
	index: number = 1;
	
	constructor(
		public user: string,
		public host: string
	) {
		super();
	}

	get length() {
		return this.user.length + 1 + this.host.length - (this.index - 1);
	}
}

export class RawPair extends RawValue {
	constructor(
		public x: number,
		public y: number
	) {
		super();
	}
}

export class RawTime extends RawValue {
	constructor(
		public hours:   number,
		public minutes: number,
		public seconds: number
	) {
		super();
	}
	
	static fromNumber(totalSeconds: number): RawTime {
		const hours = Math.floor(totalSeconds / 3600);
		const minutes = Math.floor((totalSeconds % 3600) / 60);
		const seconds = totalSeconds % 60;

		return new RawTime(hours, minutes, seconds);
	}

	toNumber(): number {
		return this.seconds + (this.minutes * 60) + (this.hours * 3600);
	}
}


/// complex compound types
export type RawDateZone = {sign: "+" | "-", hour: number, minute: number};
export class RawDate extends RawValue {
	constructor(
		public date:    Date,
		public hasTime: boolean,
		public zone:    RawDateZone = {sign: "+", hour: 0, minute: 0}
	) {
		super();
	}
}

export class RawTuple extends RawValue {
	constructor(public values: number[]) {
		super();
		
		if(values.length < 3 || values.length > 12) {
			throw new Error("Invalid number of values for a tuple!");
		}
	}

	pick(i: number) {
		if(i < 1 || i > 12) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return this.values[i - 1];
	}

	get length() {
		return this.values.length;
	}
}


/// misc
export class RawTypeset extends RawValue {
	constructor(public types: RawDatatype[]) {
		super();
	}
}

export class RawUnset extends RawValue {
	static readonly unset = new RawUnset();
}


/// aliases
export type RawAllWord =
	| RawWord | RawLitWord | RawGetWord | RawSetWord | RawRefinement | RawIssue;

export type RawAnyWord =
	| RawWord | RawLitWord | RawGetWord | RawSetWord;

export type RawAnyPath =
	| RawPath | RawLitPath | RawGetPath | RawSetPath;

export type RawSeries =
	| RawString
	| RawAnyPath
	| RawParen | RawBlock | RawHash | RawVector
	| RawBinary
	| RawFile | RawUrl | RawEmail | RawTag;

export type RawAnyString =
	| RawString | RawFile | RawUrl | RawTag | RawEmail;

export type RawAnyBlock =
	| RawBlock | RawParen | RawAnyPath | RawHash;

export type RawNumber =
	| RawInteger | RawFloat | RawPercent;

export type RawScalar =
	| RawChar | RawInteger | RawFloat | RawPair | RawPercent | RawMoney
	| RawTuple | RawTime | RawDate;

export type RawAnyFunc =
	| RawFunction | Action | Native | Op /*| Routine*/;

export type AnyType =
	| RawUnset | RawNone | RawLogic | RawBlock | RawParen | RawString | RawFile | RawUrl | RawTag | RawBitset
	| RawChar | RawInteger | RawFloat | RawAllWord | RawAnyPath | Native | Action | Op | RawFunction
	| Context | RawObject | RawTypeset | RawMap | RawHash | RawBinary
	| RawVector | RawPair | RawPercent | RawTime | RawEmail | RawDate
	| RawDatatype;


/// contexts
export class Context extends RawValue {
	static $ = new Context();
	
	outer?: Context;
	words:  string[] = [];
	values: AnyType[] = [];
	
	constructor(
		outer?:  Context,
		entries: [string, AnyType][] = []
	) {
		super();

		this.outer = outer;
		
		if(entries.length > 0) {
			for(const [word, value] of entries) {
				this.addWord(word, value);
			}
		}
	}
	
	hasWord(
		word:          string,
		caseSensitive: boolean = false,
		recursive:     boolean = false
	): boolean {
		if(caseSensitive) {
			return this.words.includes(word) || (
				recursive && this.outer !== undefined && this.outer.hasWord(word, true, true)
			);
		} else {
			return this.words.find(w => w.toLowerCase() == word.toLowerCase()) !== undefined || (
				recursive && this.outer !== undefined && this.outer.hasWord(word, false, true)
			);
		}
	}

	getWord<T extends RawValue = AnyType>(
		word:          string,
		caseSensitive: boolean = false,
		recursive:     boolean = false
	): T {
		const index = caseSensitive
			? this.words.indexOf(word)
			: this.words.findIndex(w => w.toLowerCase() == word.toLowerCase());
		
		if(index == -1) {
			if(recursive && this.outer) {
				return this.outer.getWord<T>(word, caseSensitive, true);
			} else {
				throw new Error(`Error: Undefined word "${word}" in context!`);
			}
		} else {
			return this.values[index] as T;
		}
	}

	setWord(
		word:          string,
		value:         AnyType,
		caseSensitive: boolean = false,
		recursive:     boolean = false
	) {
		const index = caseSensitive
			? this.words.indexOf(word)
			: this.words.findIndex(w => w.toLowerCase() == word.toLowerCase());
		
		if(index == -1) {
			if(recursive && this.outer) {
				this.outer.setWord(word, value, caseSensitive, true);
			} else {
				throw new Error(`Error: Undefined word "${word}" in in context!`);
			}
		} else {
			this.values[index] = value;
		}
	}

	addWord(
		word:          string,
		value:         AnyType,
		caseSensitive: boolean = false,
		recursive:     boolean = false
	) {
		const index = caseSensitive
			? this.words.indexOf(word)
			: this.words.findIndex(w => w.toLowerCase() == word.toLowerCase());
		
		if(index == -1) {
			if(recursive && this.outer && this.outer.hasWord(word, caseSensitive, true)) {
				this.outer.addWord(word, value, caseSensitive, true);
			} else {
				this.words.push(word);
				this.values.push(value);
			}
		} else {
			this.values[index] = value;
		}
	}

	removeWord(
		word:          string,
		caseSensitive: boolean = false,
		recursive:     boolean = false
	) {
		const index = caseSensitive
			? this.words.indexOf(word)
			: this.words.findIndex(w => w.toLowerCase() == word.toLowerCase());
		
		if(index == -1) {
			if(recursive && this.outer && this.outer.hasWord(word, caseSensitive, true)) {
				this.outer.removeWord(word, caseSensitive, true);
			}
		} else {
			this.words.splice(index, 1);
			this.values.splice(index, 1);
		}
	}
}

export class RawObject extends Context {
	static id: number = 0;
	
	id: number;
	
	constructor(
		outer?:  Context,
		parent?: RawObject,
		entries: [string, AnyType][] = [],
	) {
		super(outer);
		
		if(parent === undefined) {
			this.id = ++RawObject.id;
		} else {
			this.id = parent.id;
			this.words = [...parent.words];
			this.values = [...parent.values];
		}

		if(entries.length > 0) {
			for(const [word, value] of entries) {
				this.addWord(word, value);
			}
		}
	}
}


/// functions
export class RawArgument {
	constructor(
		public name:     RawWord|RawLitWord|RawGetWord,
		public typeSpec: RawBlock|null = null,
		public docSpec:  RawString|null = null
	) {}
}

export class RawFuncRefine {
	constructor(
		public ref:     RawRefinement,
		public docSpec: RawString|null,
		public addArgs: RawArgument[]
	) {}
}

export class RawFunction extends RawValue {
	arity:  number;

	constructor(
		public name:    string,
		public docSpec: RawString|null,
		public args:    RawArgument[],
		public refines: RawFuncRefine[],
		public retSpec: RawBlock|null,
		public body:    RawBlock,
		public locals:  string[] = []
	) {
		super();

		this.arity = args.length;

		const localsIndex = refines.findIndex(ref => ref.ref.word.name.toLowerCase() == "local");
		if(localsIndex != -1) {
			for(const local of refines[localsIndex].addArgs) {
				if(local.name instanceof RawWord) {
					this.locals.push(local.name.name);
				} else {
					throw new Error("error!");
				}
			}

			//this.refines.splice(localsIndex, 1);
		}
	}

	getRefine(ref: RawRefinement): RawFuncRefine {
		return this.refines.find(r => r.ref.word.name == ref.word.name)!;
	}
}

export class Native extends RawValue {
	arity: number;

	constructor(
		public name:    string,
		public docSpec: RawString|null,
		public args:    RawArgument[],
		public refines: RawFuncRefine[],
		public retSpec: RawBlock|null,
		public func:    Function
	) {
		super();

		this.arity = args.length;
	}

	getRefine(ref: RawRefinement): RawFuncRefine {
		return this.refines.find(r => r.ref.word.name == ref.word.name)!;
	}
}

export class Action extends RawValue {
	arity: number;

	constructor(
		public name:    string,
		public docSpec: RawString|null,
		public args:    RawArgument[],
		public refines: RawFuncRefine[],
		public retSpec: RawBlock|null,
		public func:    Function
	) {
		super();

		this.arity = args.length
	}

	getRefine(ref: RawRefinement): RawFuncRefine {
		return this.refines.find(r => r.ref.word.name == ref.word.name)!;
	}
}

export class Op extends RawValue {
	name: string;
	func: Native|Action|RawFunction;

	constructor(
		name: string,
		func: Native|Action|RawFunction
	) {
		super();
		
		if(func.refines.length == 0 && func.arity == 2) {
			this.name = name;
			this.func = func;
		} else {
			throw new Error("Red Error: an op! must take 2 arguments with no refinements!");
		}
	}

	get arity() {return this.func.arity}
	get args() {return this.func.args}
	get refines() {return this.func.refines}

	getRefine(_ref: RawRefinement): never {
		throw new Error("Ops may not have refinements!");
	}
}

/// utility
export enum ValueType {
	value,
	datatype,
	unset,
	none,
	logic,
	block,
	paren,
	string,
	file,
	url,
	char,
	integer,
	float,
	symbol,
	context,
	word,
	setWord,
	litWord,
	getWord,
	refinement,
	issue,
	native,
	action,
	op,
	function,
	path,
	litPath,
	setPath,
	getPath,
	routine,
	bitset,
	point,
	object,
	typeset,
	error,
	vector,
	hash,
	pair,
	percent,
	tuple,
	map,
	binary,
	series,
	time,
	tag,
	email,
	handle,
	date,
	port,
	image,
	event,
	closure,
	money
}

export const Types: Function[] = [
	RawValue,
	RawDatatype,
	RawUnset,
	RawNone,
	RawLogic,
	RawBlock,
	RawParen,
	RawString,
	RawFile,
	RawUrl,
	RawChar,
	RawInteger,
	RawFloat,
	null as any, //RawSymbol,
	Context,
	RawWord,
	RawSetWord,
	RawLitWord,
	RawGetWord,
	RawRefinement,
	RawIssue,
	Native,
	Action,
	Op,
	RawFunction,
	RawPath,
	RawLitPath,
	RawSetPath,
	RawGetPath,
	null, //RawRoutine,
	RawBitset,
	null, //RawPoint,
	RawObject,
	RawTypeset,
	null, //RawError,
	RawVector,
	RawHash,
	RawPair,
	RawPercent,
	RawTuple,
	RawMap,
	RawBinary,
	null, //RawSeries,
	RawTime,
	RawTag,
	RawEmail,
	null, //RawHandle,
	RawDate,
	null, //RawPort,
	null, //RawImage,
	null, //RawEvent,
	null, //RawClosure,
	RawMoney
];

export const TypeNames = [
	"red-value!",
	"datatype!",
	"unset!",
	"none!",
	"logic!",
	"block!",
	"paren!",
	"string!",
	"file!",
	"url!",
	"char!",
	"integer!",
	"float!",
	"symbol!",
	"context!",
	"word!",
	"set-word!",
	"lit-word!",
	"get-word!",
	"refinement!",
	"issue!",
	"native!",
	"action!",
	"op!",
	"function!",
	"path!",
	"lit-path!",
	"set-path!",
	"get-path!",
	"routine!",
	"bitset!",
	"point!",
	"object!",
	"typeset!",
	"error!",
	"vector!",
	"hash!",
	"pair!",
	"percent!",
	"tuple!",
	"map!",
	"binary!",
	"series!",
	"time!",
	"tag!",
	"email!",
	"handle!",
	"date!",
	"port!",
	"image!",
	"event!",
	"closure!",
	"money!"
];

export function typeOf(val: AnyType): ValueType {
	for(let i = 0; i < Types.length; i++) {
		if(Types[i] != null) {
			if(val.constructor === Types[i]) {
				return i;
			}
		}
	}

	return ValueType.value;
}

export function typeName(val: AnyType): string {
	return TypeNames[typeOf(val)];
}

export function wrap(value: number): RawInteger|RawFloat;
export function wrap(value: string): RawString;
export function wrap(value: boolean): RawLogic;
export function wrap(value: any[]): RawBlock;
export function wrap(value: Map<any, any>): RawMap;
export function wrap(value: null): RawNone;
export function wrap(value: undefined): RawUnset; // maybe change that idk
export function wrap(value: Date): RawDate;
//export function wrap(value: DataView): RawBinary
export function wrap(value: object): RawObject;
export function wrap(value: any): AnyType {
	if(typeof value == "number") {
		if(value % 1 == 0) {
			return new RawInteger(value);
		} else {
			return new RawFloat(value);
		}
	} else if(typeof value == "string") {
		return RawString.fromJsString(value);
	} else if(typeof value == "boolean") {
		return RawLogic.from(value);
	} else if(value === null) {
		return RawNone.none;
	} else if(value === undefined) {
		return RawUnset.unset;
	} else if(value instanceof Array) {
		return new RawBlock(value.map(v => wrap(v)));
	} else if(value instanceof Map) {
		return new RawMap(Array.from(value.entries()).map(([k, v]) => [wrap(k), wrap(v)]));
	} else if(value instanceof Date) {
		return new RawDate(value, true);
	} else if(value instanceof DataView) {
		throw new Error("unimplemented!");
	} else if(typeof value == "object") {
		const obj = new RawObject();

		for(const k of Object.getOwnPropertyNames(value)) {
			obj.addWord(k, wrap(value[k]), true);
		}
		
		return obj;
	} else {
		throw new Error(`Cannot wrap ${value}!`);
	}
}

export function todo(): never {
	throw new Error("This feature has not been implemented yet!");
}


/// type checking
export function isScalar(value: AnyType): value is RawScalar {
	const names = "integer! float! percent! money! char! pair! tuple! time! date!";
	return names.includes(typeName(value));
}

export function isSeries(value: AnyType): value is RawSeries {
	const names = "block! paren! string! file! url! path! lit-path! set-path! get-path! vector! hash! binary! tag! email! image!".split(" ");
	return names.includes(typeName(value));
}

export function isAnyWord(value: AnyType): value is RawAnyWord {
	return value instanceof RawWord || value instanceof RawLitWord || value instanceof RawGetWord || value instanceof RawSetWord;
}

export function isAllWord(value: AnyType): value is RawAllWord {
	return isAnyWord(value) || value instanceof RawRefinement || value instanceof RawIssue;
}

export function isAnyPath(value: AnyType): value is RawAnyPath {
	return value instanceof RawPath || value instanceof RawLitPath || value instanceof RawGetPath || value instanceof RawSetPath;
}

export function isAnyString(value: AnyType): value is RawAnyString {
	return value instanceof RawString || value instanceof RawFile || value instanceof RawUrl || value instanceof RawTag || value instanceof RawEmail;
}

/// control flow
//export class RawError

export class CFReturn {
	constructor(public ret?: AnyType) {}
}

export class CFBreak {
	constructor(public ret?: AnyType) {}
}

export class CFContinue {}


/// Comparing
export enum ComparisonOp {
	EQUAL,
	NOT_EQUAL,
	STRICT_EQUAL,
	LESSER,
	LESSER_EQUAL,
	GREATER,
	GREATER_EQUAL,
	SORT,
	CASE_SORT,
	SAME,
	STRICT_EQUAL_WORD,
	FIND
}

export namespace ComparisonOp {
	export function flip(op: ComparisonOp) {
		switch(op) {
			case ComparisonOp.LESSER:        return ComparisonOp.GREATER;
			case ComparisonOp.LESSER_EQUAL:  return ComparisonOp.GREATER_EQUAL;
			case ComparisonOp.GREATER:       return ComparisonOp.LESSER;
			case ComparisonOp.GREATER_EQUAL: return ComparisonOp.LESSER_EQUAL;
			default:                         return op;
		}
	}
}

export type CompareResult =
	| -2          // Bad
	| -1          // Less
	| (0 | false) // Same
	| (1 | true); // More