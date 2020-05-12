import * as Red from "../../red-types";
import RedActions from "../actions";

export function $$make(
	_ctx: Red.Context,
	_proto: Red.AnyType,
	spec: Red.AnyType
): Red.RawBlock {
	if(spec instanceof Red.RawInteger || spec instanceof Red.RawFloat) {
		return new Red.RawBlock([]);
	} else if(Red.isAnyPath(spec)) {
		return new Red.RawBlock(spec.path.slice(spec.index-1));
	} else if(spec instanceof Red.RawBlock || spec instanceof Red.RawParen /*|| spec instanceof Red/RawHash*/) {
		return new Red.RawBlock(spec.values.slice(spec.index-1));
	} else if(spec instanceof Red.Context || spec instanceof Red.RawObject) {
		const blk: Red.AnyType[] = [];

		for(let i = 0; i < spec.words.length; i++) {
			blk.push(new Red.RawSetWord(spec.words[i]));
			blk.push(spec.values[i]);
		}

		return new Red.RawBlock(blk);
	} /* else if(spec instanceof Red.RawMap) {
		...
	} */ else if(spec instanceof Red.RawVector) {
		return new Red.RawBlock(spec.values.slice(spec.index-1));
	} else {
		throw TypeError("Cannot create a block! from an instance of " + Red.TYPE_NAME(spec));
	}
}

// $$to

export function $$form(
	ctx: Red.Context,
	block: Red.RawBlock,
	buffer: string[],
	part?: number
): boolean {
	const blk = block.values.slice(block.index-1);

	if(blk.length == 0) {
		buffer.push("");
	} else {
		RedActions.$valueSendAction("$$form", ctx, blk[0], buffer, part);

		for(const val of blk.slice(1)) {
			buffer.push(" ");
			RedActions.$valueSendAction("$$form", ctx, val, buffer, part);
		}
	}

	return false;
}

export function $$mold(
	ctx: Red.Context,
	block: Red.RawBlock,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const blk = block.values.slice(block.index-1);

	if(blk.length == 0) {
		buffer.push("[]");
	} else {
		buffer.push("[");
		
		RedActions.$valueSendAction("$$mold", ctx, blk[0], buffer, indent, _);

		for(const val of blk.slice(1)) {
			buffer.push(" ");
			RedActions.$valueSendAction("$$mold", ctx, val, buffer, indent, _);
		}

		buffer.push("]");
	}

	return false;
}

// $compare

// $evalPath

export function $$copy(
	ctx: Red.Context,
	block: Red.RawBlock,
	_: RedActions.CopyOptions = {}
): Red.RawBlock {
	if(_.part !== undefined || _.types !== undefined) {
		Red.todo();
	}

	const blk = block.values.slice(block.index-1);
	
	if(_.deep !== undefined) {
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
	_ctx:   Red.Context,
	series: Red.RawBlock,
	value:  Red.AnyType,
	_: RedActions.AppendOptions = {}
): Red.RawBlock {
	if(_.part !== undefined || _.dup !== undefined) {
		Red.todo();
	} else if(_.only !== undefined) {
		series.values.push(value);
	} else {
		if(value instanceof Red.RawBlock /*|| value instanceof Red.RawHash*/ || value instanceof Red.RawParen) {
			series.values.push(...value.values.slice(value.index - 1));
		} else if(Red.isAnyPath(value)) {
			series.values.push(...value.path.slice(value.index - 1));
		} else {
			series.values.push(value);
		}
	}

	return series;
}