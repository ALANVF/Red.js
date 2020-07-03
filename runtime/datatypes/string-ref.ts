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
	map?: (s: string, v?: typeof value) => string,
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