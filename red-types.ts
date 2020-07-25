import {Ref} from "./helper-types";
import {Vector} from "./types/typed-vector";

interface Series {
	index:  number;
	length: number;
}

// temporary
interface SeriesOf<T> extends Series {
	pick(i: number): T;
	poke(i: number, v: T): void;
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
	constructor(public value: number) {
		super();

		if(value % 1 != 0) {
			throw new TypeError("Internal error: Expected an integer but got a float instead!");
		}
	}
}

export class RawFloat extends RawValue {
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

	get upperChar() {
		if(97 <= this.char && this.char <= 122) {
			return this.char - 32;
		} else {
			return this.char;
		}
	}
	
	get lowerChar() {
		if(65 <= this.char && this.char <= 90) {
			return this.char + 32;
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
export class RawString extends RawValue implements SeriesOf<RawChar> {
	index: number = 1;

	constructor(public values: RawChar[]) {
		super();
	}

	static fromJsString(value: string) {
		return new RawString([...value].map(c => RawChar.fromJsChar(c)));
	}

	static fromRedString(value: string) {
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

		return new RawString(out);
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
	
	poke(
		i: number,
		v: RawChar
	) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		this.values[(this.index - 1) + (i - 1)] = v;
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
	
	get absLength() {
		return this.values.length;
	}
}

export class RawParen extends RawValue implements SeriesOf<AnyType> {
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
	
	poke(
		i: number,
		v: AnyType
	) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		this.values[(this.index - 1) + (i - 1)] = v;
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

export class RawBlock extends RawValue implements SeriesOf<AnyType> {
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
	
	poke(
		i: number,
		v: AnyType
	) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		this.values[(this.index - 1) + (i - 1)] = v;
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
export class RawBinary extends RawValue implements SeriesOf<number> {
	index: number = 1;
	
	constructor(public bytes: Ref<Buffer>) {
		super();
	}

	pick(i: number) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return this.bytes.ref[(this.index - 1) + (i - 1)];
	}
	
	poke(
		i: number,
		v: number
	) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		this.bytes.ref[(this.index - 1) + (i - 1)] = v;
	}

	current(): RawBinary {
		if(this.index == 1) {
			return this;
		} else {
			return new RawBinary(this.bytes.copyWith(ref => ref.copyWithin(0, this.index - 1)));
		}
	}

	get length() {
		return this.bytes.ref.length - (this.index - 1);
	}
}

export class RawBitset extends RawValue {
	// For reference:
	// https://github.com/red/red/blob/master/runtime/datatypes/bitset.reds
	// https://github.com/rebol/rebol/blob/master/src/core/t-bitset.c#L202
	// https://github.com/rebol/rebol/blob/master/src/core/f-enbase.c#L422
	// https://github.com/red/red/blob/master/runtime/datatypes/bitset.reds#L565
	// https://github.com/red/red/blob/master/runtime/macros.reds#L505
	
	bytes:   Uint8Array;
	negated: boolean;
	
	private toByte(bit: number) {
		return 1 << (7 - (bit & 7));
	}
	
	constructor(
		bits:    number[] | number,
		negated: boolean
	) {
		super();
		
		if(typeof bits == "number") {
			this.bytes = new Uint8Array((bits - 1 << 3) + 1);
		} else if(bits.length == 0) {
			this.bytes = new Uint8Array();
		} else {
			this.bytes = new Uint8Array((Math.max(...bits) >> 3) + 1);
			
			for(const bit of bits) {
				this.bytes[bit >> 3] += this.toByte(bit);
			}
		}
		
		this.negated = negated;
	}
	
	hasBit(
		bit:     number,
		_noCase: boolean = false // ignore noCase for now
	): boolean {
		const i = bit >> 3;
		
		if(i >= this.bytes.length) {
			return this.negated;
		} else {
			return ((this.toByte(bit) & this.bytes[i]) != 0) != this.negated;
		}
	}
	
	setBit(
		bit:    number,
		status: boolean
	) {
		const i = bit >> 3;
		const byte = this.toByte(bit);
		
		if(this.negated == status) {
			if(i < this.bytes.length) {
				this.bytes[i] &= ~byte;
			}
		} else {
			if(i > this.bytes.length) {
				this.bytes = new Uint8Array([
					...this.bytes,
					...Array(i - this.bytes.length).fill(0),
					byte
				]);
			} else {
				this.bytes[i] |= byte;
			}
		}
	}
}

export class RawHash extends RawValue implements SeriesOf<AnyType> {
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
	
	poke(
		i: number,
		v: AnyType
	) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		this.values[(this.index - 1) + (i - 1)] = v;
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
			if(key instanceof RawWord || key instanceof RawLitWord || key instanceof RawGetWord) {
				this.keys.push(new RawSetWord(key.name));
			} else {
				this.keys.push(key);
			}
			
			this.values.push(val);
		}
	}
}

export class RawFile extends RawValue implements SeriesOf<RawChar> {
	index: number = 1;

	constructor(public name: Ref<string>) {
		super();
	}
	
	pick(i: number): RawChar {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return new RawChar(this.name.ref.charCodeAt((this.index - 1) + (i - 1)));
	}
	
	poke(
		i: number,
		v: AnyType
	) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		if(v instanceof RawChar) {
			const index = (this.index - 1) + (i - 1);
			this.name.set(ref => ref.slice(0, index - 1) + v.toJsChar() + ref.slice(index));
		} else {
			throw new Error(`Unexpected ${typeName(v)}`);
		}
	}
	
	current(): RawFile {
		if(this.index == 1) {
			return this;
		} else {
			return new RawFile(this.name.copyWith(ref => ref.slice(this.index - 1)));
		}
	}

	get length() {
		return this.name.ref.length - (this.index - 1);
	}
}

export class RawTag extends RawValue implements SeriesOf<RawChar> {
	index: number = 1;
	
	constructor(public tag: Ref<string>) {
		super();
	}
	
	pick(i: number): RawChar {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return new RawChar(this.tag.ref.charCodeAt((this.index - 1) + (i - 1)));
	}
	
	poke(
		i: number,
		v: AnyType
	) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		if(v instanceof RawChar) {
			const index = (this.index - 1) + (i - 1);
			this.tag.set(ref => ref.slice(0, index - 1) + v.toJsChar() + ref.slice(index));
		} else {
			throw new Error(`Unexpected ${typeName(v)}`);
		}
	}
	
	current(): RawTag {
		if(this.index == 1) {
			return this;
		} else {
			return new RawTag(this.tag.copyWith(ref => ref.slice(this.index - 1)));
		}
	}

	get length() {
		return this.tag.ref.length - (this.index - 1);
	}
}

export class RawUrl extends RawValue implements Series {
	index: number = 1;
	
	constructor(public url: Ref<string>) {
		super();
	}

	get length() {
		return this.url.ref.length - (this.index - 1);
	}
}

export class RawVector extends RawValue implements SeriesOf<number> {
	index: number = 1;

	constructor(public values: Vector) {
		super();
	}
	
	toRedValues(): AnyType[] {
		switch(this.values.elemType) {
			case "integer!": return [...this.values.repr].map(v => new RawInteger(v));
			case "float!":   return [...this.values.repr].map(v => new RawFloat(v));
			case "percent!": return [...this.values.repr].map(v => new RawPercent(v));
			case "char!":    return [...this.values.repr].map(v => new RawChar(v));
		}
	}
	
	pickBoxed(i: number) {
		const value = this.pick(i);
		switch(this.values.elemType) {
			case "integer!": return new RawInteger(value);
			case "float!":   return new RawFloat(value);
			case "percent!": return new RawPercent(value);
			case "char!":    return new RawChar(value);
		}
	}

	pick(i: number) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		return this.values.get((this.index - 1) + (i - 1));
	}
	
	poke(
		i: number,
		v: number
	) {
		if(i < 1 || i > this.length) {
			throw new Error(`Invalid index: ${i}`);
		}
		
		this.values.set((this.index - 1) + (i - 1), v);
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
	
	constructor(public email: Ref<string>) {
		super();
	}

	get length() {
		return this.email.ref.length - (this.index - 1);
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

export type RawAnyList =
	| RawBlock | RawParen | RawHash;

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
	money,
	ref
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
	RawMoney,
	null //RawRef
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
	"money!",
	"ref!"
];

export const Datatypes: Record<string, RawDatatype> = {};
for(const [i, v] of Types.entries()) {
	if(v != null) {
		const name = TypeNames[i];
		Datatypes[name] = new RawDatatype(name, v);
	}
}

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

// TODO: make typed arrays return a vector
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
	} else if(value instanceof RawValue) {
		return value;
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

export function difficult(): never {
	throw new Error("This is difficult to implement, so it'll be a while until it's implemented");
}

export function sameSeries(
	ser1: RawSeries,
	ser2: typeof ser1
): boolean {
	if(isAnyList(ser1) || ser1 instanceof RawString || ser1 instanceof RawVector) {
		return ser1.values === (<typeof ser1>ser2).values;
	} else if(ser1 instanceof RawFile) {
		return ser1.name === (<typeof ser1>ser2).name;
	} else if(ser1 instanceof RawTag) {
		return ser1.tag === (<typeof ser1>ser2).tag;
	} else if(ser1 instanceof RawEmail) {
		return ser1.email === (<typeof ser1>ser2).email;
	} else if(ser1 instanceof RawUrl) {
		return ser1.url === (<typeof ser1>ser2).url;
	} else if(ser1 instanceof RawBinary) {
		return ser1.bytes === (<typeof ser1>ser2).bytes;
	} else {
		return ser1.path === (<typeof ser1>ser2).path;
	}
}


/// type checking
export function isScalar(value: AnyType): value is RawScalar {
	const names = "integer! float! percent! money! char! pair! tuple! time! date!";
	return names.includes(typeName(value));
}

export function isSeries(value: AnyType): value is RawSeries {
	const names = "block! paren! string! file! url! path! lit-path! set-path! get-path! vector! hash! binary! tag! email! image! ref!".split(" ");
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

export function isNumber(value: AnyType): value is RawNumber {
	return value instanceof RawInteger || value instanceof RawFloat || value instanceof RawPercent;
}

export function isAnyList(value: AnyType): value is RawAnyList {
	return value instanceof RawBlock || value instanceof RawParen || value instanceof RawHash;
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