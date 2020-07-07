import * as Red from "../../red-types";
import RedActions from "../actions";
import {evalSingle} from "../eval";
import {StringBuilder} from "../../helper-types";

/* Native actions */
export function $evalPath(
	ctx:     Red.Context,
	pair :   Red.RawPair,
	value:   Red.AnyType,
	_isCase: boolean
): Red.RawInteger {
	let getVal: Red.AnyType;

	if(value instanceof Red.RawWord) {
		getVal = value;
	} else {
		getVal = evalSingle(ctx, value, false);
	}
	
	if(getVal instanceof Red.RawWord) {
		if(getVal.name.toLowerCase() == "x") {
			return new Red.RawInteger(pair.x);
		} else if(getVal.name.toLowerCase() == "y") {
			return new Red.RawInteger(pair.y);
		}
	}
	
	throw new Error(`Invalid accessor ${value}`);
}

export function $setPath(
	ctx:      Red.Context,
	pair:     Red.RawPair,
	value:    Red.AnyType,
	newValue: Red.AnyType,
	isCase:   boolean
): Red.AnyType {
	let getVal: Red.AnyType;

	if(value instanceof Red.RawWord) {
		getVal = value;
	} else {
		getVal = evalSingle(ctx, value, false);
	}

	if(getVal instanceof Red.RawWord) {
		if(newValue instanceof Red.RawInteger) {
			if(getVal.name.toLowerCase() == "x") {
				pair.x = newValue.value;
				return newValue;
			} else if(getVal.name.toLowerCase() == "y") {
				pair.y = newValue.value;
				return newValue;
			}
		} else {
			throw new Error(`Unexpected ${Red.typeName(newValue)}`);
		}
	}
	
	throw new Error(`Invalid accessor ${value}`);
}

/* Actions */
export function $$form(
	_ctx:    Red.Context,
	pair:    Red.RawPair,
	builder: StringBuilder,
	_part?:  number
): boolean {
	builder.push(`${pair.x}x${pair.y}`);
	return false;
}

export function $$mold(
	ctx:     Red.Context,
	pair:    Red.RawPair,
	builder: StringBuilder,
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	return $$form(ctx, pair, builder, _.part);
}