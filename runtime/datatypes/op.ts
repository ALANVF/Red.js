import * as Red from "../../red-types";

export function $$make(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.RawAnyFunc
): Red.Op {
	if(spec instanceof Red.Op) {
		return spec;
	} else {
		return new Red.Op(spec.name, spec);
	}
}

export function $$form(
	_ctx:   Red.Context,
	_value: Red.Op,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push("?op?");
	return false;
}