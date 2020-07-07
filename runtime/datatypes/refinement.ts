import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

// $$make

export function $$form(
	_ctx:    Red.Context,
	value:   Red.RawRefinement,
	builder: StringBuilder,
	_part?:  number
): boolean {
	if(value.name instanceof Red.RawWord) {
		builder.push(value.name.name);
	} else {
		builder.push(value.name.value.toString());
	}
	
	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	value:   Red.RawRefinement,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	builder.push("/");
	
	if(value.name instanceof Red.RawWord) {
		builder.push(value.name.name);
	} else {
		builder.push(value.name.value.toString());
	}

	return false;
}