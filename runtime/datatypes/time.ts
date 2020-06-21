import * as Red from "../../red-types";
import RedActions from "../actions";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	time:   Red.RawTime,
	buffer: string[],
	_part?: number
): boolean {
	const minutes = Math.abs(time.minutes);
	const seconds = Math.abs(time.seconds);
	
	if(time.hours < 0 || time.minutes < 0 || time.seconds < 0) {
		buffer.push("-");
	}
	
	buffer.push(Math.abs(time.hours).toString());
	buffer.push(":");
	buffer.push((minutes < 10 ? "0" : "") + minutes.toString());
	buffer.push(":");
	buffer.push((seconds < 10 ? "0" : "") + seconds.toString());
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	time:    Red.RawTime,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, time, buffer, _.part);
}