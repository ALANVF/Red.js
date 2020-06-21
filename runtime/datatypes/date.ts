import * as Red from "../../red-types";
import RedActions from "../actions";

/* Actions */
export function $$form(
	_ctx:   Red.Context,
	date:   Red.RawDate,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push(date.date.getUTCDate().toString());
	buffer.push("-");
	buffer.push("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec".split(" ")[date.date.getUTCMonth()]);
	buffer.push("-");
	buffer.push(date.date.getUTCFullYear().toString());
	
	if(date.hasTime) {
		const minutes = date.date.getUTCMinutes();
		const seconds = date.date.getUTCSeconds();
		const mseconds = date.date.getUTCMilliseconds();
		
		buffer.push("/");
		buffer.push(date.date.getUTCHours().toString());
		buffer.push(":");
		buffer.push((minutes < 10 ? "0" : "") + minutes.toString());
		buffer.push(":");
		buffer.push((seconds < 10 ? "0" : "") + seconds.toString());
		
		if(mseconds != 0) {
			buffer.push(".");
			buffer.push(mseconds.toString());
		}
		
		if(date.zone.hour + date.zone.minute != 0) {
			buffer.push(date.zone.sign);
			buffer.push((date.zone.hour < 10 ? "0" : "") + date.zone.hour.toString());
			buffer.push(":");
			buffer.push((date.zone.minute < 10 ? "0" : "") + date.zone.minute.toString());
		}
	}
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	date:    Red.RawDate,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, date, buffer, _.part);
}