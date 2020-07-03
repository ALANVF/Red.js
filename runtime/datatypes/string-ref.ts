import {Ref} from "../../helper-types";
import * as Red from "../../red-types";
import RedActions from "../actions";

//type StringLike = Red.RawFile | Red.RawUrl | Red.RawTag /*| Red.RawEmail*/;



export function insert(
	ctx:   Red.Context,
	str:   Ref<string>,
	index: number,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {},
	map?: (s: string, v?: typeof value) => string,
): number {
	let addStr: string;
	
	if(value instanceof Red.RawChar) {
		addStr = value.toJsChar();
	} else if(value instanceof Red.RawString) {
		addStr = value.toJsString();
	} else if(Red.isAnyList(value)) {
		addStr = "";
		for(const elem of value.current().values) {
			addStr += RedActions.$$form(ctx, elem).toJsString();
		}
	} else if(value instanceof Red.RawFile) {
		addStr = value.current().name.ref;
	} else {
		addStr = RedActions.$$form(ctx, value).toJsString();
	}
	
	if(map !== undefined) {
		addStr = map(addStr, value);
	}
	
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