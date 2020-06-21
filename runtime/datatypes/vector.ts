import * as Red from "../../red-types";
import RedActions from "../actions";

export function $$form(
	ctx:    Red.Context,
	vector: Red.RawVector,
	buffer: string[],
	part?:  number
): boolean {
	const blk = vector.values.slice(vector.index-1);

	if(blk.length == 0) {
		buffer.push("");
	} else {
		RedActions.valueSendAction("$$form", ctx, blk[0], buffer, part);

		for(const val of blk.slice(1)) {
			buffer.push(" ");
			RedActions.valueSendAction("$$form", ctx, val, buffer, part);
		}
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
	const blk = vector.values.slice(vector.index-1);

	buffer.push("make vector! [")
	
	if(blk.length == 0) {
		buffer.push("]");
	} else {
		RedActions.valueSendAction("$$mold", ctx, blk[0], buffer, indent, _);

		for(const val of blk.slice(1)) {
			buffer.push(" ");
			RedActions.valueSendAction("$$mold", ctx, val, buffer, indent, _);
		}

		buffer.push("]");
	}

	return false;
}