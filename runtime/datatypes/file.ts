import * as Red from "../../red-types";
import RedActions from "../actions";
import {append, insert, change} from "./string-ref";
import {$$skip} from "./series";
import {StringBuilder} from "../../helper-types";

function encodeFileString(str: string): string {
	let a: ReturnType<typeof str.match>;
	
	if(str.length == 0) {
		return str;
	} else if(a = str.match(/^\^([@\-\/A-Z\[\\\]_])/)) {
		return "%" + a[1].charCodeAt(0).toString(16).toUpperCase() + encodeFileString(str.slice(2));
	} else if(a = str.match(/^\^(["^])/)) {
		return a[1] + encodeFileString(str.slice(1));
	} else if(a = str.match(/^[\s()\[\]{}<>%]/)) {
		return "%" + a[0].charCodeAt(0).toString(16).toUpperCase() + encodeFileString(str.slice(1));
	} else {
		return str[0] + encodeFileString(str.slice(1));
	}
}

/* Actions */
export function $$form(
	_ctx:    Red.Context,
	file:    Red.RawFile,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push(file.current().name.ref);
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	file:    Red.RawFile,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	builder.push("%");
	return $$form(ctx, file, builder, _.part);
}

// ...

export function $$append(
	ctx:   Red.Context,
	file:  Red.RawFile,
	value: Red.AnyType,
	_: RedActions.AppendOptions = {}
): Red.RawFile {
	append(ctx, file.name, value, _, (str, val) => {
		if(val instanceof Red.RawFile) {
			return str;
		} else {
			return encodeFileString(str);
		}
	});
	
	return file;
}

export function $$insert(
	ctx:   Red.Context,
	file:  Red.RawFile,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {}
): Red.RawFile {
	return $$skip(ctx, file, insert(ctx, file.name, file.index - 1, value, _, (str, val) => {
		if(val instanceof Red.RawFile) {
			return str;
		} else {
			return encodeFileString(str);
		}
	}));
}

export function $$change(
	ctx:   Red.Context,
	file:  Red.RawFile,
	value: Red.AnyType,
	_: RedActions.ChangeOptions = {}
): Red.RawFile {
	return $$skip(ctx, file, change(ctx, file.name, file.index - 1, value, _, (str, val) => {
		if(val instanceof Red.RawFile) {
			return str;
		} else {
			return encodeFileString(str);
		}
	}));
}