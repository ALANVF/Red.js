import * as Red from "../../red-types";
import RedActions from "../actions";
import {$$skip} from "./series";

function insertOnly(
	list:    Red.AnyType[],
	value:   Red.AnyType,
	index:   number
) {
	list.splice(index, 0, value);
}

function insertAll(
	list:    Red.AnyType[],
	values:  Red.AnyType[],
	index:   number,
	length?: number
): number {
	if(length !== 0) {
		if(length === undefined || length >= values.length) {
			list.splice(index, 0, ...values);
			return values.length;
		} else {
			list.splice(index, 0, ...values.slice(0, length));
		}
	}
	 
	return length;
}

/* Actions */
// $compare

// $$make

// $$to

export function $$form(
	ctx:    Red.Context,
	value:  Red.RawPath,
	buffer: string[],
	part?:  number
): boolean {
	const [head, ...rest] = value.path.slice(value.index - 1);

	RedActions.valueSendAction("$$form", ctx, head, buffer, part);
	for(const val of rest) {
		buffer.push("/");
		RedActions.valueSendAction("$$form", ctx, val, buffer, part);
	}

	return false;
}

export function $$mold(
	ctx:    Red.Context,
	value:  Red.RawPath,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const [head, ...rest] = value.path.slice(value.index - 1);
	
	RedActions.valueSendAction("$$mold", ctx, head, buffer, indent, _);
	for(const val of rest) {
		buffer.push("/");
		RedActions.valueSendAction("$$mold", ctx, val, buffer, indent, _);
	}

	return false;
}

// ...

export function $$append(
	_ctx:  Red.Context,
	path:  Red.RawAnyPath,
	value: Red.AnyType,
	_: RedActions.AppendOptions = {}
): Red.RawAnyPath {
	if(_.only !== undefined || !(Red.isAnyList(value) || Red.isAnyPath(value))) {
		if(_.dup !== undefined) {
			for(let i = 0; i < _.dup; i++) {
				path.path.push(value);
			}
		} else {
			path.path.push(value);
		}
	} else {
		const values = "values" in value ? value.current().values : value.current().path;
		if(_.dup !== undefined) {
			for(let i = 0; i < _.dup; i++) {
				path.path.push(...values);
			}
		} else if(_.part !== undefined) {
			path.path.push(...values.slice(0, _.part));
		} else {
			path.path.push(...values);
		}
	}
	
	return path;
}

// ...

export function $$insert(
	ctx:   Red.Context,
	path:  Red.RawAnyPath,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {}
): typeof path {
	const index = path.index - 1;
	let offset = 0;
	
	if(_.dup !== undefined) {
		const dups = [];
		
		if(_.only !== undefined) {
			for(let i = 0; i < _.dup; i++) dups.push(value);
		} else if(value instanceof Red.RawBlock || value instanceof Red.RawHash || value instanceof Red.RawParen) {
			const values = value.current().values;
			for(let i = 0; i < _.dup; i++) dups.push(...values);
		} else if(Red.isAnyPath(value)) {
			const values = value.current().path;
			for(let i = 0; i < _.dup; i++) dups.push(...values);
		} else {
			for(let i = 0; i < _.dup; i++) dups.push(value);
		}
		
		path.path.splice(index, 0, ...dups);
		offset += dups.length;
	} else if(_.only !== undefined) {
		insertOnly(path.path, value, index);
		offset++;
	} else {
		if(value instanceof Red.RawBlock || value instanceof Red.RawHash || value instanceof Red.RawParen) {
			offset += insertAll(path.path, value.current().values, index, _.part);
		} else if(Red.isAnyPath(value)) {
			offset += insertAll(path.path, value.current().path, index, _.part);
		} else {
			insertOnly(path.path, value, index);
			offset++;
		}
	}

	return $$skip(ctx, path, offset);
}

export function $$change(
	ctx:   Red.Context,
	path:  Red.RawAnyPath,
	value: Red.AnyType,
	_: RedActions.ChangeOptions = {}
): typeof path {
	const index = path.index - 1;
	let offset = 0;
	
	if(_.dup !== undefined) {
		const dups = [];
		
		if(_.only !== undefined) {
			for(let i = 0; i < _.dup; i++) dups.push(value);
		} else if(value instanceof Red.RawBlock || value instanceof Red.RawHash || value instanceof Red.RawParen) {
			const values = value.current().values;
			for(let i = 0; i < _.dup; i++) dups.push(...values);
		} else if(Red.isAnyPath(value)) {
			const values = value.current().path;
			for(let i = 0; i < _.dup; i++) dups.push(...values);
		} else {
			for(let i = 0; i < _.dup; i++) dups.push(value);
		}
		
		path.path.splice(index, dups.length, ...dups);
		offset += dups.length;
	} else if(_.only !== undefined) {
		path.path[index] = value;
		offset++;
	} else {
		if(value instanceof Red.RawBlock || value instanceof Red.RawHash || value instanceof Red.RawParen) {
			const values = value.current().values;
			
			if(_.part === undefined) {
				path.path.splice(index, values.length, ...values);
				offset += values.length;
			} else {
				path.path.splice(index, _.part, ...values.slice(0, _.part));
				offset += _.part;
			}
		} else if(Red.isAnyPath(value)) {
			const values = value.current().path;
			
			if(_.part === undefined) {
				path.path.splice(index, values.length, ...values);
				offset += values.length;
			} else {
				path.path.splice(index, _.part, ...values.slice(0, _.part));
				offset += _.part;
			}
		} else {
			path.path[index] = value;
			offset++;
		}
	}

	return $$skip(ctx, path, offset);
}