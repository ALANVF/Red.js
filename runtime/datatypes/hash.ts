import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

export function $$mold(
	ctx:     Red.Context,
	hash:    Red.RawHash,
	builder: StringBuilder,
	indent:  number,
	_: RedActions.MoldOptions = {}
) {
	const blk = hash.values.slice(hash.index-1);

	builder.push("make hash! [")
	
	if(blk.length == 0) {
		builder.push("]");
	} else {
		RedActions.valueSendAction("$$mold", ctx, blk[0], builder, indent, _);

		for(const val of blk.slice(1)) {
			builder.push(" ");
			RedActions.valueSendAction("$$mold", ctx, val, builder, indent, _);
		}

		builder.push("]");
	}
}