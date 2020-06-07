import * as Red from "../red-types";

// system/words/preprocessor from compiled Red is a nice thing to look at for reference.

class MacroFunction {
	constructor(
		public name: string,
		public args: Red.RawBlock,
		public body: Red.RawBlock
	) {}
}

interface MacroPattern {
	pattern: Red.AnyType[];
	body:    Red.RawBlock;
}

class MacroCtx {
	// TODO: maybe change these 2 properties to Maps
	defines:  {names: string[], values: Red.AnyType[]};
	macros:   {names: string[], funcs:  MacroFunction[]};
	patterns: MacroPattern[];

	constructor(
		public ctx:  Red.Context,
		public body: Red.RawBlock
	) {
		this.defines = {names: [], values: []};
		this.macros = {names: [], funcs: []};
		this.patterns = [];
	}
}

// TODO: remove this function because it doesn't seem to be necessary
export function pre1(
	ctx:  Red.Context,
	body: Red.RawBlock
) {
	const values = body.values;
	
	for(let i = body.values.length-1; i >= 0; i--) {
		const value = values[i];
		
		if(value instanceof Red.RawIssue) {
			//values[i] = value;

			// why does this exist
			/*if(value.value == "macro") {
				values[i + 1] = values[i + 1];
				values[i + 2] = values[i + 2];
				values[i + 3] = values[i + 3];
				values[i + 4] = values[i + 4];
			}*/

			continue;
		}
	}

	body.values = values;
	return new MacroCtx(ctx, body);
}

function pre2(mc: MacroCtx) {
	const values = mc.body.values;
	const stack = [];

	for(let i = values.length-1; i >= 0; i--) {
		const value = values[i];
		const stack0 = stack[0];

		if(value instanceof Red.RawIssue && value.value == "define" && stack0 instanceof Red.RawWord) {
			mc.defines.names.push(stack0.name);
			mc.defines.values.push(stack[1]);
			stack.splice(0, 2);
		} else if(value instanceof Red.RawIssue && value.value == "macro" && stack0 instanceof Red.RawSetWord) {
			mc.macros.names.push(stack0.word.name);
			const mfunc = new MacroFunction(stack0.name, stack[2] as Red.RawBlock, stack[3] as Red.RawBlock);
			stack.splice(0, 4);
			mc.macros.funcs.push(mfunc);
		} else if(value instanceof Red.RawIssue && value.value == "include" && stack0 instanceof Red.RawFile) {
			stack.unshift(new Red.RawWord("do"));
		} else {
			stack.unshift(values[i]);
		}
	}

	mc.body = new Red.RawBlock(stack);
	return mc;
}

// will do true macros later. too complex for me :<

function pre3(mc: MacroCtx) {
	const values = mc.body.values;

	for(let i = values.length; i >= 0; i--) {
		const value = values[i];

		if(value instanceof Red.RawWord) {
			if(mc.defines.names.includes(value.name)) {
				const v = mc.defines.values[mc.defines.names.indexOf(value.name)];
				
				if(v instanceof Red.RawBlock) {
					values.splice(i, 1, ...pre(mc.ctx, v).values);
				} else {
					values[i] = v;
				}
			}
		}
	}

	/*for(const macro of mc.macros.funcs) {
		values.push(macro);
	}*/
	
	return new Red.RawBlock(values);
}

export function pre(ctx: Red.Context, body: Red.RawBlock) {
	return pre3(pre2(pre1(ctx, body)));
}