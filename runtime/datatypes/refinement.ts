import * as Red from "../../red-types";
import RedActions from "../actions";

// $$make

export function $$form(
	_ctx:   Red.Context,
	value:  Red.RawRefinement,
	buffer: string[],
	_part?: number
): boolean {
	if(value.name instanceof Red.RawWord) {
		buffer.push(value.name.name);
	} else {
		buffer.push(value.name.value.toString());
	}
	
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawRefinement,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	buffer.push("/");
	
	if(value.name instanceof Red.RawWord) {
		buffer.push(value.name.name);
	} else {
		buffer.push(value.name.value.toString());
	}

	return false;
}