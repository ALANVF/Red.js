import * as Red from "../../red-types";
import RedActions from "../actions";

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
	ctx:    Red.Context,
	op:     Red.Op,
	buffer: string[],
	indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const lastIndent = " ".repeat((indent-1)*4);
	const thisIndent = " ".repeat(indent*4);
	const value = op.func;

	buffer.push("make op! [[");
	
	if(value.docSpec != null) {
		buffer.push(RedActions.$$mold(ctx, value.docSpec).toJsString());
	}

	for(const arg of value.args) {
		buffer.push("\n" + thisIndent);
		RedActions.valueSendAction("$$mold", ctx, arg.name, buffer, indent + 1, _);
		
		if(arg.typeSpec != null) {
			buffer.push(" ");
			RedActions.valueSendAction("$$mold", ctx, arg.typeSpec, buffer, indent + 1, _);
		}

		if(arg.docSpec != null) {
			buffer.push(" ");
			RedActions.valueSendAction("$$mold", ctx, arg.docSpec, buffer, indent + 1, _);
		}
	}
	
	if(value.retSpec != null) {
		buffer.push("\n" + thisIndent + "return: ");
		RedActions.valueSendAction("$$mold", ctx, value.retSpec, buffer, indent + 1, _);
	}

	if(value.arity == 0 && value.refines.length == 0) {
		buffer.push("]]");
		return false;
	} else {
		buffer.push("\n" + lastIndent + "]]");
		return true;
	}
}

export function $$form(
	_ctx:   Red.Context,
	_op:    Red.Op,
	buffer: string[],
	_part?: number
): boolean {
	buffer.push("?op?");
	return false;
}