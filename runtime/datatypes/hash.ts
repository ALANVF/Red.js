import * as Red from "../../red-types";
import RedActions from "../actions";

export function $$mold(
	ctx:    Red.Context,
	hash:   Red.RawHash,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const blk = hash.values.slice(hash.index-1);

	buffer.push("make hash! [")
	
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