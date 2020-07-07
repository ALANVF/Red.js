import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

/* Actions */
export function $$form(
	_ctx:    Red.Context,
	time:    Red.RawTime,
	builder: StringBuilder,
	_part?:  number
): boolean {
	const minutes = Math.abs(time.minutes);
	const seconds = Math.abs(time.seconds);
	
	if(time.hours < 0 || time.minutes < 0 || time.seconds < 0) {
		builder.push("-");
	}
	
	builder.push(Math.abs(time.hours).toString());
	builder.push(":");
	builder.push((minutes < 10 ? "0" : "") + minutes.toString());
	builder.push(":");
	builder.push((seconds < 10 ? "0" : "") + seconds.toString());
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	time:    Red.RawTime,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, time, builder, _.part);
}