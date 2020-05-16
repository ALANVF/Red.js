import * as Red from "../../red-types";
import RedActions from "../actions";

export function $$make(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.RawBlock
): Red.RawFunction {
	let docSpec = null, retSpec = null;
	const args = [], refines = [], fspec = spec.values[0] as Red.RawBlock;

	if(fspec.values[0] instanceof Red.RawString) {
		docSpec = fspec.values[0];
		fspec.values.splice(0, 1);
	}

	while(fspec.values[0] instanceof Red.RawWord || fspec.values[0] instanceof Red.RawGetWord || fspec.values[0] instanceof Red.RawLitWord) {
		const hasSpec = fspec.values[1] instanceof Red.RawBlock;

		if(fspec.values[1 + +hasSpec] instanceof Red.RawString) {
			args.push({
				name: fspec.values[0],
				typeSpec: hasSpec ? fspec.values[1] : null,
				docSpec: fspec.values[1 + +hasSpec]
			});

			fspec.values.splice(0, 2 + +hasSpec);
		} else {
			args.push({
				name: fspec.values[0],
				typeSpec: hasSpec ? fspec.values[1] : null,
				docSpec: null
			});

			fspec.values.splice(0, 1 + +hasSpec);
		}
	}
	
	while(fspec.values[0] instanceof Red.RawRefinement) {
		const a = [];
		let s = null;

		if(fspec.values[1] instanceof Red.RawString) {
			s = fspec.values[1];
			fspec.values.splice(1, 1);
		}

		while(fspec.values[1] instanceof Red.RawWord || fspec.values[1] instanceof Red.RawGetWord || fspec.values[1] instanceof Red.RawLitWord) {
			const hasSpec = fspec.values[2] instanceof Red.RawBlock;

			if(fspec.values[2 + +hasSpec] instanceof Red.RawString) {
				a.push({
					name: fspec.values[1],
					typeSpec: hasSpec ? fspec.values[2] : null,
					docSpec: fspec.values[2 + +hasSpec]
				});

				fspec.values.splice(1, 2 + +hasSpec);
			} else {
				a.push({
					name: fspec.values[1],
					typeSpec: hasSpec ? fspec.values[2] : null,
					docSpec: null
				});

				fspec.values.splice(1, 1 + +hasSpec);
			}
		}

		refines.push({
			ref: fspec.values[0],
			docSpec: s,
			addArgs: a
		});

		fspec.values.shift();
	}

	if(fspec.values[0] instanceof Red.RawSetWord && (fspec.values[0] as Red.RawSetWord).name == "return") {
		retSpec = fspec.values[1];
		fspec.values.splice(0, 2);
	}

	return new Red.RawFunction(
		"",
		docSpec as any,
		args as any[],
		refines as any[],
		retSpec as any,
		spec.values[1] as Red.RawBlock
	);
}

export function $$form(
	ctx:    Red.Context,
	value:  Red.RawFunction,
	buffer: string[],
	part?:  number
): boolean {
	$$mold(ctx, value, buffer, 1, {part});
	return true;
}

export function $$mold(
	ctx:    Red.Context,
	value:  Red.RawFunction,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const lastIndent = " ".repeat((indent-1)*4);
	const thisIndent = " ".repeat(indent*4);
	const nextIndent = " ".repeat((indent+1)*4);
	
	buffer.push(lastIndent + "make function! [[");
	
	if(value.docSpec != null) {
		buffer.push(RedActions.$$mold(ctx, value.docSpec).toJsString());
	}

	for(const arg of value.args) {
		buffer.push("\n" + thisIndent);
		buffer.push(RedActions.$$mold(ctx, arg.name).toJsString());
		
		if(arg.typeSpec != null) {
			buffer.push(" ");
			buffer.push(RedActions.$$mold(ctx, arg.typeSpec).toJsString());
		}

		if(arg.docSpec != null) {
			buffer.push(" ");
			buffer.push(RedActions.$$mold(ctx, arg.docSpec).toJsString());
		}
	}

	for(const ref of value.refines) {
		buffer.push("\n" + thisIndent);
		buffer.push(RedActions.$$mold(ctx, ref.ref).toJsString());

		if(ref.docSpec != null) {
			buffer.push(" ");
			buffer.push(RedActions.$$mold(ctx, ref.docSpec).toJsString());
		}

		for(const arg of ref.addArgs) {
			buffer.push("\n" + nextIndent);
			buffer.push(RedActions.$$mold(ctx, arg.name).toJsString());
			
			if(arg.typeSpec != null) {
				buffer.push(" ");
				buffer.push(RedActions.$$mold(ctx, arg.typeSpec).toJsString());
			}

			if(arg.docSpec != null) {
				buffer.push(" ");
				buffer.push(RedActions.$$mold(ctx, arg.docSpec).toJsString());
			}
		}
	}

	if(value.retSpec != null) {
		buffer.push("\n" + thisIndent + "return: ");
		buffer.push(RedActions.$$mold(ctx, value.retSpec).toJsString());
	}

	if(value.arity != 0) {
		buffer.push("\n" + lastIndent);
	}

	buffer.push("]");
	buffer.push(RedActions.$$mold(ctx, value.body).toJsString());
	buffer.push("]");

	return true;
}