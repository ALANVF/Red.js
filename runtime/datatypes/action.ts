import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

export function $$make(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.RawBlock
): Red.Action {
	let docSpec = null, retSpec = null;
	const args = [], refines = [], aspec = spec.values[0] as Red.RawBlock;

	if(aspec.values[0] instanceof Red.RawString) {
		docSpec = aspec.values[0];
		aspec.values.splice(0, 1);
	}

	while(aspec.values[0] instanceof Red.RawWord || aspec.values[0] instanceof Red.RawGetWord || aspec.values[0] instanceof Red.RawLitWord) {
		const hasSpec = aspec.values[1] instanceof Red.RawBlock;

		if(aspec.values[1 + +hasSpec] instanceof Red.RawString) {
			args.push({
				name: aspec.values[0],
				typeSpec: hasSpec ? aspec.values[1] : null,
				docSpec: aspec.values[1 + +hasSpec]
			});

			aspec.values.splice(0, 2 + +hasSpec);
		} else {
			args.push({
				name: aspec.values[0],
				typeSpec: hasSpec ? aspec.values[1] : null,
				docSpec: null
			});

			aspec.values.splice(0, 1 + +hasSpec);
		}
	}

	while(aspec.values[0] instanceof Red.RawRefinement) {
		const a = [];
		let s = null;

		if(aspec.values[1] instanceof Red.RawString) {
			s = aspec.values[1];
			aspec.values.splice(1, 1);
		}

		while(aspec.values[1] instanceof Red.RawWord || aspec.values[1] instanceof Red.RawGetWord || aspec.values[1] instanceof Red.RawLitWord) {
			const hasSpec = aspec.values[2] instanceof Red.RawBlock;

			if(aspec.values[2 + +hasSpec] instanceof Red.RawString) {
				a.push({
					name: aspec.values[1],
					typeSpec: hasSpec ? aspec.values[2] : null,
					docSpec: aspec.values[2 + +hasSpec]
				});

				aspec.values.splice(1, 2 + +hasSpec);
			} else {
				a.push({
					name: aspec.values[1],
					typeSpec: hasSpec ? aspec.values[2] : null,
					docSpec: null
				});

				aspec.values.splice(1, 1 + +hasSpec);
			}
		}

		refines.push({
			ref: aspec.values[0],
			docSpec: s,
			addArgs: a
		});

		aspec.values.shift();
	}

	if(aspec.values[0] instanceof Red.RawSetWord && (aspec.values[0] as Red.RawSetWord).name == "return") {
		retSpec = aspec.values[1];
		aspec.values.splice(0, 2);
	}

	return new Red.Action(
		(spec.values[1] as Red.RawWord).name,
		docSpec as any,
		args as any[],
		refines as any[],
		retSpec as any,
		(RedActions as any)["$$"+(spec.values[1] as Red.RawWord).name.toLowerCase()]
	);
}

export function $$form(
	_ctx:    Red.Context,
	_value:  Red.Action,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push("?action?");
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	value:   Red.Action,
	builder: StringBuilder,
	indent:  number,
	_: RedActions.MoldOptions = {}
): boolean {
	const lastIndent = " ".repeat((indent-1)*4);
	const thisIndent = " ".repeat(indent*4);
	const nextIndent = " ".repeat((indent+1)*4);

	builder.push("make action! [[");
	
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
		return false;
	} else {
		builder.push("\n" + lastIndent + "]]");
		return true;
	}
}