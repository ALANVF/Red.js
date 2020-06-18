import * as Red from "../../red-types";
import RedActions from "../actions";

// $$make

// $$to

export function $$form(
	_ctx:   Red.Context,
	binary: Red.RawBinary,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push("#{");
	buffer.push(binary.bytes.toString("hex"));
	buffer.push("}");
	
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	binary:  Red.RawBinary,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, binary, buffer, _.part);
}