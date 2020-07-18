import * as Red from "../../red-types";
import RedNatives from "../natives";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

export function $$make(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.RawBlock
): Red.Native {
	let docSpec = null, retSpec = null;
	const args = [], refines = [], nspec = spec.values[0] as Red.RawBlock;

	if(nspec.values[0] instanceof Red.RawString) {
		docSpec = nspec.values[0];
		nspec.values.splice(0, 1);
	}

	while(nspec.values[0] instanceof Red.RawWord || nspec.values[0] instanceof Red.RawGetWord || nspec.values[0] instanceof Red.RawLitWord) {
		const hasSpec = nspec.values[1] instanceof Red.RawBlock;

		if(nspec.values[1 + +hasSpec] instanceof Red.RawString) {
			args.push({
				name: nspec.values[0],
				typeSpec: hasSpec ? nspec.values[1] : null,
				docSpec: nspec.values[1 + +hasSpec]
			});

			nspec.values.splice(0, 2 + +hasSpec);
		} else {
			args.push({
				name: nspec.values[0],
				typeSpec: hasSpec ? nspec.values[1] : null,
				docSpec: null
			});

			nspec.values.splice(0, 1 + +hasSpec);
		}
	}

	// also fix type annotations for this as well
	while(nspec.values[0] instanceof Red.RawRefinement) {
		const a = [];
		let s = null;

		if(nspec.values[1] instanceof Red.RawString) {
			s = nspec.values[1];
			nspec.values.splice(1, 1);
		}

		while(nspec.values[1] instanceof Red.RawWord || nspec.values[1] instanceof Red.RawGetWord || nspec.values[1] instanceof Red.RawLitWord) {
			const hasSpec = nspec.values[2] instanceof Red.RawBlock;

			if(nspec.values[2 + +hasSpec] instanceof Red.RawString) {
				a.push({
					name: nspec.values[1],
					typeSpec: hasSpec ? nspec.values[2] : null,
					docSpec: nspec.values[2 + +hasSpec]
				});

				nspec.values.splice(1, 2 + +hasSpec);
			} else {
				a.push({
					name: nspec.values[1],
					typeSpec: hasSpec ? nspec.values[2] : null,
					docSpec: null
				});

				nspec.values.splice(1, 1 + +hasSpec);
			}
		}

		refines.push({
			ref: nspec.values[0],
			docSpec: s,
			addArgs: a
		});

		nspec.values.shift();
	}

	if(nspec.values[0] instanceof Red.RawSetWord && (nspec.values[0] as Red.RawSetWord).name == "return") {
		retSpec = nspec.values[1];
		nspec.values.splice(0, 2);
	}

	return new Red.Native(
		(spec.values[1] as Red.RawWord).name,
		docSpec as any,
		args as any[],
		refines as any[],
		retSpec as any,
		(RedNatives as any)["$$"+(spec.values[1] as Red.RawWord).name.toLowerCase()]
	);
}

export function $$form(
	_ctx:    Red.Context,
	_value:  Red.Native,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push("?native?");
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.Native,
	builder: StringBuilder,
	indent:  number,
	_: RedActions.MoldOptions = {}
) {
	const lastIndent = " ".repeat((indent-1)*4);
	const thisIndent = " ".repeat(indent*4);
	const nextIndent = " ".repeat((indent+1)*4);

	builder.push("make native! [[");
	
	if(value.docSpec != null) {
		builder.push(RedActions.$$mold(ctx, value.docSpec).toJsString());
	}

	for(const arg of value.args) {
		builder.push("\n" + thisIndent);
		RedActions.valueSendAction("$$mold", ctx, arg.name, builder, indent + 1, _);
		
		if(arg.typeSpec != null) {
			builder.push(" ");
			RedActions.valueSendAction("$$mold", ctx, arg.typeSpec, builder, indent + 1, _);
		}

		if(arg.docSpec != null) {
			builder.push(" ");
			RedActions.valueSendAction("$$mold", ctx, arg.docSpec, builder, indent + 1, _);
		}
	}

	for(const ref of value.refines) {
		builder.push("\n" + thisIndent);
		RedActions.valueSendAction("$$mold", ctx, ref.ref, builder, indent + 1, _);

		if(ref.docSpec != null) {
			builder.push(" ");
			RedActions.valueSendAction("$$mold", ctx, ref.docSpec, builder, indent + 1, _);
		}

		for(const arg of ref.addArgs) {
			builder.push("\n" + nextIndent);
			RedActions.valueSendAction("$$mold", ctx, arg.name, builder, indent + 1, _);
			
			if(arg.typeSpec != null) {
				builder.push(" ");
				RedActions.valueSendAction("$$mold", ctx, arg.typeSpec, builder, indent + 1, _);
			}

			if(arg.docSpec != null) {
				builder.push(" ");
				RedActions.valueSendAction("$$mold", ctx, arg.docSpec, builder, indent + 1, _);
			}
		}
	}

	if(value.retSpec != null) {
		builder.push("\n" + thisIndent + "return: ");
		RedActions.valueSendAction("$$mold", ctx, value.retSpec, builder, indent + 1, _);
	}

	if(value.arity == 0 && value.refines.length == 0) {
		builder.push("]]");
	} else {
		builder.push("\n" + lastIndent + "]]");
	}
}