interface Series {
	index: number;
	length: number;
}

export class RawValue {
	isTruthy(): boolean {
		return true;
	}
}

export class RawDatatype extends RawValue {
	constructor(public name: string, public repr: Function) {
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

	get word(): RawWord {
		return this;
	}
}

export class RawLitWord extends RawValue {
	name: string;
	
	constructor(ident: RawWord|string) {
		super();

		if(typeof ident == "string") {
			this.name = ident;
		} else {
			this.name = ident.name;
		}
	}

	get word() {
		return new RawWord(this.name);
	}
}

export class RawGetWord extends RawValue {
	name: string;
	
	constructor(ident: RawWord|string) {
		super();

		if(typeof ident == "string") {
			this.name = ident;
		} else {
			this.name = ident.name;
		}
	}

	get word() {
		return new RawWord(this.name);
	}
}

export class RawSetWord extends RawValue {
	name: string;
	
	constructor(ident: RawWord|string) {
		super();

		if(typeof ident == "string") {
			this.name = ident;
		} else {
			this.name = ident.name;
		}
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

	get length() {
		return this.path.length - (this.index - 1);
	}
}

export class RawLitPath extends RawValue implements Series {
	index: number = 1;
	
	constructor(public path: AnyType[]) {
		super();
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

	get length() {
		return this.path.length - (this.index - 1);
	}
}

export class RawSetPath extends RawValue implements Series {
	index: number = 1;
	
	constructor(public path: AnyType[]) {
		super();
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
	constructor(public char: string) {
		super();
	}

	static fromNormalChar(char: string) {
		switch(char) {
			case "\"":   return new RawChar("^\"");
			case "^":    return new RawChar("^^");
			case "\x1c": return new RawChar("^\\");
			case "\x1d": return new RawChar("^]");
			case "\x1f": return new RawChar("^_");

			case "\0":   return new RawChar("^@");
			case "\x08": return new RawChar("^(back)");
			case "\t":   return new RawChar("^-");
			case "\n":   return new RawChar("^/");
			case "\x0c": return new RawChar("^(page)");
			case "\x1b": return new RawChar("^[");
			case "\x7f": return new RawChar("^~");

			default: {
				if(char.match(/^[\x01-\x1a]$/)) {
					return new RawChar("^" + String.fromCharCode(char.charCodeAt(0) + 64));
				} else if(char == "\x1e") {
					return new RawChar("^(1E)");
				} else if(char.length == 1) {
					return new RawChar(char);
				} else {
					throw new Error(`Invalid char! literal #"${char}"!`);
				}
			}
		}
	}

	toNormalChar() {
		if(this.char[0] == "^") {
			const esc = this.char.slice(1).toUpperCase();
			switch(esc) {
				case "\"": return "\"";
				case "^":  return "^";
				case "\\": return "\x1c";
				case "]":  return "\x1d";
				case "_":  return "\x1f";

				case "@": case "(NULL)": return "\0";
				          case "(BACK)": return "\x08";
				case "-": case "(TAB)":  return "\t";
				case "/": case "(LINE)": return "\n";
				          case "(PAGE)": return "\x0c";
				case "[": case "(ESC)":  return "\x1b";
				case "~": case "(DEL)":  return "\x7f";

				default: {
					if(esc.match(/^[A-Z]$/)) {
						return String.fromCharCode(esc.charCodeAt(0) - 64);
					} else if(esc.match(/^\(([A-F\d]+)\)$/)) {
						return String.fromCharCode(parseInt(RegExp.$1, 16));
					} else {
						throw new Error(`Invalid char! literal #"^${esc}"!`);
					}
				}
			}
		} else {
			return this.char;
		}
	}
}
export class RawLogic extends RawValue {
	constructor(public cond: boolean) {
		super();
	}

	isTruthy(): boolean {
		return this.cond;
	}
}

export class RawNone extends RawValue {
	isTruthy(): boolean {
		return false;
	}
}


/// series types
export class RawString extends RawValue implements Series {
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
		return new RawString([...value].map(c => RawChar.fromNormalChar(c)), multiline);
	}

	static fromNormalString(
		value:     string,
		multiline: boolean = false
	) {
		const out = [];
		const redEscapeChar = /\^(?:[A-Z\[\\\]_@\-\/~"\^]||\((?:\h+|null|back|tab|line|page|esc|del)\))/i;

		while(value != "") {
			if(value.search(redEscapeChar) == 0) {
				const m = redEscapeChar.exec(value)!;
				out.push(new RawChar(m.toString()));
				value = value.slice(m.toString().length);
			} else {
				out.push(new RawChar(value[0]));
				value = value.slice(1);
			}
		}

		return new RawString(out, multiline);
	}

	toJsString() {
		return this.values.slice(this.index - 1).map(char => char.toNormalChar()).join("");
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

	at(i: number) {
		if(i < 1) throw new Error(`Invalid index: ${i}`);
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

export class RawBlock extends RawValue implements Series {
	index: number = 1;

	constructor(public values: AnyType[]) {
		super();
	}

	at(i: number) {
		if(i < 1) throw new Error(`Invalid index: ${i}`);
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
export class RawBinary extends RawValue implements Series {
	index: number = 1;
	
	constructor(public bytes: Uint8Array) {
		super();
	}

	at(i: number) {
		if(i < 1) throw new Error(`Invalid index: ${i}`);
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

export class RawHash extends RawValue implements Series {
	index: number = 1;
	
	constructor(public values: AnyType[]) {
		super();
	}

	at(i: number) {
		if(i < 1) throw new Error(`Invalid index: ${i}`);
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
export class RawVector extends RawValue implements Series {
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
		public x: RawInteger,
		public y: RawInteger
	) {
		super();
	}
}

export class RawTime extends RawValue {
	constructor(
		public hours:   RawInteger,
		public minutes: RawInteger,
		public seconds: RawInteger|RawFloat
	) {
		super();
	}
	
	static fromNumber(totalSeconds: number): RawTime {
		const hours = Math.floor(totalSeconds / 3600);
		const minutes = Math.floor((totalSeconds % 3600) / 60);
		const seconds = totalSeconds % 60;
		
		return new RawTime(new RawInteger(hours), new RawInteger(minutes), new RawInteger(seconds));
	}

	toNumber(): number {
		return this.seconds.value + (this.minutes.value * 60) + (this.hours.value * 3600);
	}
}


/// complex compound types
export class RawDate extends RawValue {
	constructor(public date: Date) {
		super();
	}
}

export class RawTuple extends RawValue {
	constructor(public values: RawInteger[]) {
		super();
		
		if(values.length < 3 || values.length > 12) {
			throw new Error("Invalid number of values for a tuple!");
		}
	}
}


/// misc
export class RawTypeset extends RawValue {
	constructor(public types: RawDatatype[]) {
		super();
	}
}

export class RawUnset extends RawValue {}


/// aliases
export type RawAllWord = RawWord | RawLitWord | RawGetWord | RawSetWord | RawRefinement | RawIssue;

export type RawAnyWord = RawWord | RawLitWord | RawGetWord | RawSetWord;

export type RawAnyPath = RawPath | RawLitPath | RawGetPath | RawSetPath;

export type RawSeries =
	| RawString
	| RawAnyPath
	| RawParen | RawBlock | RawHash | RawVector
	| RawBinary
	| RawFile | RawUrl | RawEmail | RawTag;

export type RawAnyString = RawString | RawFile | RawUrl | RawTag | RawEmail;

export type RawAnyBlock = RawBlock | RawParen | RawAnyPath | RawHash;

export type RawNumber = RawInteger | RawFloat | RawPercent | RawMoney;

export type RawScalar = RawChar | RawInteger | RawFloat | RawPair | RawPercent | RawMoney | RawTuple | RawTime | RawDate;

export type RawAnyFunc = RawFunction | Action | Native | Op /*| Routine*/;

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
			word = word.toLowerCase();
			return this.words.find(w => w.toLowerCase() == word) !== undefined || (
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

/// utility
export function TYPE_OF(val: AnyType): number {
	for(let i = 0; i < Types.length; i++) {
		if(Types[i] != null) {
			if(val.constructor === Types[i]) {
				return i;
			}
		}
	}

	return 0;
}

export function TYPE_NAME(val: AnyType): string {
	return TypeNames[TYPE_OF(val)];
}

export function wrap(value: number): RawInteger|RawFloat
export function wrap(value: string): RawString
export function wrap(value: boolean): RawLogic
export function wrap(value: any[]): RawBlock
export function wrap(value: Map<any, any>): RawMap;
export function wrap(value: null): RawNone
export function wrap(value: undefined): RawUnset // maybe change that idk
//export function wrap(value: Date): RawDate
//export function wrap(value: DataView): RawBinary
//export function wrap(value: File): RawFile
export function wrap(value: object): RawObject
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
		return new RawLogic(value);
	} else if(value === null) {
		return new RawNone();
	} else if(value === undefined) {
		return new RawUnset();
	} else if(value instanceof Array) {
		return new RawBlock(value.map(v => wrap(v)));
	} else if(value instanceof Map) {
		return new RawMap(Array.from(value.entries()).map(([k, v]) => [wrap(k), wrap(v)]));
	} else if(value instanceof Date) {
		throw new Error("unimplemented!");
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
export function isa(
	value: AnyType,
	type: RawDatatype|RawTypeset
): boolean {
	if(type instanceof RawDatatype) {
		return value.constructor === type.repr;
	} else {
		return type.types.some(ty => isa(value, ty));
	}
}

export function isSeries(value: AnyType): value is RawSeries {
	const names = "block! paren! string! file! url! path! lit-path! set-path! get-path! vector! hash! binary! tag! email! image!".split(" ");
	return names.includes(TYPE_NAME(value));
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

export type CompareResult =
	| -2          // Bad
	| -1          // Less
	| (0 | false) // Same
	| (1 | true); // More