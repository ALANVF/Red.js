import * as Red from "../../red-types";
import RedActions from "../actions";
import {tokenize} from "../../tokenizer";
import RedUtil from "../util";

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
export function $$make(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawBlock {
	if(spec instanceof Red.RawInteger || spec instanceof Red.RawFloat) {
		return new Red.RawBlock([]);
	} else if(Red.isAnyPath(spec)) {
		return new Red.RawBlock(spec.current().path);
	} else if(spec instanceof Red.RawBlock || spec instanceof Red.RawParen || spec instanceof Red.RawHash) {
		return new Red.RawBlock(spec.values.slice(spec.index-1));
	} else if(spec instanceof Red.Context || spec instanceof Red.RawObject) {
		return new Red.RawBlock(RedUtil.Arrays.zip(
			spec.words.map(w => new Red.RawSetWord(w)),
			spec.values
		).flat())
	} else if(spec instanceof Red.RawMap) {
		return new Red.RawBlock(RedUtil.Arrays.zip(spec.keys, spec.values).flat());
	} else if(spec instanceof Red.RawVector) {
		return new Red.RawBlock(spec.toRedValues().slice(spec.index-1));
	} else {
		throw new TypeError("Cannot create a block! from an instance of " + Red.typeName(spec));
	}
}

export function $$to(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawBlock {
	if(Red.isAnyPath(spec)) {
		return new Red.RawBlock(spec.current().path);
	} else if(spec instanceof Red.RawBlock || spec instanceof Red.RawParen || spec instanceof Red.RawHash) {
		return new Red.RawBlock(spec.values.slice(spec.index-1));
	} else if(spec instanceof Red.Context || spec instanceof Red.RawObject) {
		return new Red.RawBlock(RedUtil.Arrays.zip(
			spec.words.map(w => new Red.RawSetWord(w)),
			spec.values
		).flat())
	} else if(spec instanceof Red.RawMap) {
		return new Red.RawBlock(RedUtil.Arrays.zip(spec.keys, spec.values).flat());
	} else if(spec instanceof Red.RawVector) {
		return new Red.RawBlock(spec.toRedValues().slice(spec.index-1));
	} else if(spec instanceof Red.RawString) {
		return new Red.RawBlock(tokenize(spec.toJsString()));
	} else if(spec instanceof Red.RawTypeset) {
		return new Red.RawBlock([...spec.types]);
	} else {
		return new Red.RawBlock([spec]);
	}
}

export function $$form(
	ctx:    Red.Context,
	block:  Red.RawBlock,
	buffer: string[],
	part?:  number
): boolean {
	const blk = block.values.slice(block.index-1);

	if(blk.length == 0) {
		buffer.push("");
	} else {
		RedActions.valueSendAction("$$form", ctx, blk[0], buffer, part);

		for(const val of blk.slice(1)) {
			buffer.push(" ");
			RedActions.valueSendAction("$$form", ctx, val, buffer, part);
		}
	}

	return false;
}

export function $$mold(
	ctx:    Red.Context,
	block:  Red.RawBlock,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const blk = block.values.slice(block.index-1);

	if(blk.length == 0) {
		buffer.push("[]");
	} else {
		buffer.push("[");
		
		RedActions.valueSendAction("$$mold", ctx, blk[0], buffer, indent, _);

		for(const val of blk.slice(1)) {
			buffer.push(" ");
			RedActions.valueSendAction("$$mold", ctx, val, buffer, indent, _);
		}

		buffer.push("]");
	}

	return false;
}

// $compare

// $evalPath

export function $$copy(
	ctx:   Red.Context,
	block: Red.RawBlock,
	_: RedActions.CopyOptions = {}
): Red.RawBlock {
	if(_.part !== undefined || _.types !== undefined) {
		Red.todo();
	}

	const blk = block.values.slice(block.index-1);
	
	if(_.deep === undefined) {
		return new Red.RawBlock(blk);
	} else {
		return new Red.RawBlock(
			blk.map(val => {
				if(Red.isSeries(val) || val instanceof Red.Context || val instanceof Red.RawObject || val instanceof Red.RawBitset || val instanceof Red.RawMap) {
					return RedActions.$$copy(ctx, val, {deep: []});
				} else {
					return val;
				}
			})
		);
	}
}

// ...

export function $$append(
	_ctx:  Red.Context,
	list:  Red.RawAnyList,
	value: Red.AnyType,
	_: RedActions.AppendOptions = {}
): Red.RawAnyList {
	if(_.only !== undefined || !(Red.isAnyList(value) || Red.isAnyPath(value))) {
		if(_.dup !== undefined) {
			for(let i = 0; i < _.dup; i++) {
				list.values.push(value);
			}
		} else {
			list.values.push(value);
		}
	} else {
		const values = "values" in value ? value.current().values : value.current().path;
		if(_.dup !== undefined) {
			for(let i = 0; i < _.dup; i++) {
				list.values.push(...values);
			}
		} else if(_.part !== undefined) {
			list.values.push(...values.slice(0, _.part));
		} else {
			list.values.push(...values);
		}
	}
	
	return list;
}

// ...

export function $$insert(
	_ctx:  Red.Context,
	list:  Red.RawAnyList,
	value: Red.AnyType,
	_: RedActions.InsertOptions = {}
): Red.RawAnyList {
	const index = list.index - 1;
	
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
		
		list.values.splice(index, 0, ...dups);
		list.index += dups.length;
	} else if(_.only !== undefined) {
		insertOnly(list.values, value, index);
		list.index++;
	} else {
		if(value instanceof Red.RawBlock || value instanceof Red.RawHash || value instanceof Red.RawParen) {
			list.index += insertAll(list.values, value.current().values, index, _.part);
		} else if(Red.isAnyPath(value)) {
			list.index += insertAll(list.values, value.current().path, index, _.part);
		} else {
			insertOnly(list.values, value, index);
			list.index++;
		}
	}

	return list;
}