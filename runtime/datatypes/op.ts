import * as Red from "../../red-types";
import RedActions from "../actions";
import {StringBuilder} from "../../helper-types";

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

export function $$mold(
	ctx:     Red.Context,
	op:      Red.Op,
	builder: StringBuilder,
	indent:  number,
	_: RedActions.MoldOptions = {}
) {
	const lastIndent = " ".repeat((indent-1)*4);
	const thisIndent = " ".repeat(indent*4);
	const value = op.func;

	builder.push("make op! [[");
	
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

export function $$form(
	_ctx:    Red.Context,
	_op:     Red.Op,
	builder: StringBuilder,
	_part?:  number
) {
	builder.push("?op?");
}