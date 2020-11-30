import {Ref} from "../../helper-types";
import * as Red from "../../red-types";
import RedActions from "../actions";

function stringifyArg(
	ctx:   Red.Context,
	value: Red.AnyType,
	map?:  (s: string, v?: typeof value) => string
): string {
	let newStr: string;
	
	if(value instanceof Red.RawChar) {
		newStr = value.toJsChar();
	} else if(value instanceof Red.RawString) {
		newStr = value.toJsString();
	} else if(Red.isAnyList(value)) {
		newStr = "";
		for(const elem of value.current().values) {
			newStr += RedActions.$$form(ctx, elem).toJsString();
		}
	} else if(value instanceof Red.RawFile) {
		newStr = value.current().name.ref;
	} else {
		newStr = RedActions.$$form(ctx, value).toJsString();
	}
	
	if(map !== undefined) {
		newStr = map(newStr, value);
	}
	
	return newStr;
}

export function find(
	ctx:   Red.Context,
	str:   Ref<string>,
	index: number,
	value: Red.AnyType,
	_:     RedActions.FindOptions = {}
) {
	let str1 = str.ref;
	const isPart = _.part !== undefined;
	let isCase = _.case !== undefined;
	const isSame = _.same !== undefined;
	const isAny = _.any !== undefined;
	const isWith = _.with !== undefined;
	const isLast = _.last !== undefined;
	let isReverse = _.reverse !== undefined;
	const isTail = _.tail !== undefined;
	const isMatch = _.match !== undefined;
	
	if(index >= str.ref.length && !(index != 0 && isReverse)) {
		return Red.RawNone.none;
	}
	
	let wasFound = false;
	let matchLength: number;
	let step = 1;
	let limit = str.ref.length;
	let begin = 1;
	let end = str.ref.length;
	
	// Options processing
	if(isAny || isWith) {
		Red.todo();
	}
	
	if(_.skip !== undefined && _.skip > 0) {
		step = _.skip;
	}
	
	if(_.part !== undefined) {
		if(_.part > 0) {
			limit = _.part;
		} else {
			return Red.RawNone.none;
		}
	}
	
	if(isLast) {
		step = -step;
		end = isPart ? begin - limit + 1 : begin;
		begin = str.ref.length;
	} else if(isReverse) {
		step = -step;
		begin = index;
		end = isPart ? begin - limit + 1 : 1;
		
		if(begin == 0 || isMatch) {
			return Red.RawNone.none;
		}
	} else {
		end = isPart ? limit : str.ref.length;
	}
	
	isCase = Red.isAnyString(value) ? isCase : false;
	
	if(isSame) {
		isCase = false;
	}
	
	isReverse = isReverse || isLast;
	
	let canFind: (s: string) => boolean;
	
	// Value arguments processing
	if(value instanceof Red.RawChar) {
		const char = isCase ? value.char : value.upperChar;
		matchLength = 1;
		canFind = s => s.charCodeAt(0) == char;
	} else if(value instanceof Red.RawBitset) {
		isCase = false;
		matchLength = 1;
		canFind = s => value.hasBit(s.charCodeAt(0));
	} else if(Red.isAnyString(value) || value instanceof Red.RawBinary || value instanceof Red.RawWord) {
		let str2: string;
		
		if(value instanceof Red.RawWord) {
			str2 = value.name;
		} else if(value instanceof Red.RawString) {
			str2 = value.toJsString();
		} else if(value instanceof Red.RawBinary) {
			str2 = value.bytes.ref.toString();
		} else {
			str2 = RedActions.$$form(ctx, value).toJsString();
		}
		
		str2 = isCase ? str2 : str2.toUpperCase();
		matchLength = str2.length;
		canFind = s => s.startsWith(str2);
	} else {
		return Red.RawNone.none;
	}
	
	str1 = isCase ? str1 : str1.toUpperCase();
	
	const isDone = isReverse ? ((a: number, b: number) => a >= b) : ((a: number, b: number) => a <= b);
	
	if(isMatch) {
		wasFound = canFind(str1.slice(begin - 1));
	} else {
		for(; isDone(begin, end); begin += step) {
			if(wasFound = canFind(str1.slice(begin - 1))) {
				break;
			}
		}
	}
	
	if(wasFound) {
		if(isTail || isMatch) {
			begin += matchLength;
		}
		
		return begin - 1;
	} else {
		return Red.RawNone.none;
	}
}

export function append(
	ctx:   Red.Context,
	str:   Ref<string>,
	value: Red.AnyType,
	_: RedActions.AppendOptions = {},
	map?: (s: string, v?: typeof value) => string,
) {
	const addStr = stringifyArg(ctx, value, map);
	
	if(_.dup !== undefined) {
		for(let i = 0; i < _.dup; i++) {
			str.ref += addStr;
		}
	} else if(_.part !== undefined) {
		str.ref += addStr.slice(0, _.part);
	} else {
		str.ref += addStr;
	}
}

export function insert(
	ctx:   Red.Context,
	str:   Ref<string>,
	index: number,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {},
	map?: (s: string, v?: typeof value) => string
): number {
	const addStr = stringifyArg(ctx, value, map);
	
	if(_.dup !== undefined) {
		let dups = "";
		
		for(let i = 0; i < _.dup; i++) {
			dups += addStr;
		}
		
		str.set(ref => ref.slice(0, index) + dups + ref.slice(index));
		
		return dups.length;
	} else if(_.part !== undefined) {
		str.set(ref => ref.slice(0, index) + addStr.slice(0, _.part) + ref.slice(index));
		
		return _.part;
	} else {
		str.set(ref => ref.slice(0, index) + addStr + ref.slice(index));
		
		return addStr.length;
	}
}

export function change(
	ctx:   Red.Context,
	str:   Ref<string>,
	index: number,
	value: Red.AnyType,
	_: RedActions.ChangeOptions = {},
	map?: (s: string, v?: typeof value) => string
): number {
	const addStr = stringifyArg(ctx, value, map);
	
	if(_.dup !== undefined) {
		let dups = "";
		
		for(let i = 0; i < _.dup; i++) {
			dups += addStr;
		}
		
		str.set(ref => ref.slice(0, index) + dups + ref.slice(index + dups.length));
		
		return dups.length;
	} else if(_.part !== undefined) {
		str.set(ref => ref.slice(0, index) + addStr.slice(0, _.part) + ref.slice(index + _.part!));
		
		return _.part;
	} else {
		str.set(ref => ref.slice(0, index) + addStr + ref.slice(index + addStr.length));
		
		return addStr.length;
	}
}