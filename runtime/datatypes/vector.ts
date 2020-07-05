import * as Red from "../../red-types";
import RedActions from "../actions";

export function $$form(
	ctx:    Red.Context,
	vector: Red.RawVector,
	buffer: string[],
	part?:  number
): boolean {
	const blk = vector.values.repr.slice(vector.index-1);
	
	let mapping: (v: number) => string;
	
	switch(vector.values.elemType) {
		case "integer!": mapping = v => v.toFixed(0);                                break;
		case "float!":   mapping = v => v % 1 == 0 ? v.toFixed(1) : v.toString();    break;
		case "percent!": mapping = v => (v * 100).toString() + "%";                  break;
		case "char!":    mapping = v => '#"' + new Red.RawChar(v).toRedChar() + '"'; break;
	}
	
	buffer.push(mapping(blk[0]));

	for(const val of blk.slice(1)) {
		buffer.push(" ");
		buffer.push(mapping(val));
	}

	return false;
}

export function $$mold(
	ctx:    Red.Context,
	vector: Red.RawVector,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const blk = vector.values.repr.slice(vector.index-1);
	
	buffer.push("make vector! [")
	
	if(blk.length == 0) {
		buffer.push("]");
	} else {
		let mapping: (v: number) => string;
		
		switch(vector.values.elemType) {
			case "integer!": mapping = v => v.toFixed(0);                                break;
			case "float!":   mapping = v => v % 1 == 0 ? v.toFixed(1) : v.toString();    break;
			case "percent!": mapping = v => (v * 100).toString() + "%";                  break;
			case "char!":    mapping = v => '#"' + new Red.RawChar(v).toRedChar() + '"'; break;
		}
		
		buffer.push(mapping(blk[0]));

		for(const val of blk.slice(1)) {
			buffer.push(" ");
			buffer.push(mapping(val));
		}

		buffer.push("]");
	}

	return false;
}