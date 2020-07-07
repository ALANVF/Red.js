import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

/* Actions */
export function $$form(
	_ctx:    Red.Context,
	date:    Red.RawDate,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push(date.date.getUTCDate().toString());
	builder.push("-");
	builder.push("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec".split(" ")[date.date.getUTCMonth()]);
	builder.push("-");
	builder.push(date.date.getUTCFullYear().toString());
	
	if(date.hasTime) {
		const minutes = date.date.getUTCMinutes();
		const seconds = date.date.getUTCSeconds();
		const mseconds = date.date.getUTCMilliseconds();
		
		builder.push("/");
		builder.push(date.date.getUTCHours().toString());
		builder.push(":");
		builder.push((minutes < 10 ? "0" : "") + minutes.toString());
		builder.push(":");
		builder.push((seconds < 10 ? "0" : "") + seconds.toString());
		
		if(mseconds != 0) {
			builder.push(".");
			builder.push(mseconds.toString());
		}
		
		if(date.zone.hour + date.zone.minute != 0) {
			builder.push(date.zone.sign);
			builder.push((date.zone.hour < 10 ? "0" : "") + date.zone.hour.toString());
			builder.push(":");
			builder.push((date.zone.minute < 10 ? "0" : "") + date.zone.minute.toString());
		}
	}
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	date:    Red.RawDate,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, date, builder, _.part);
}