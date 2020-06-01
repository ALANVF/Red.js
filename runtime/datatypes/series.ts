import * as Red from "../../red-types";
import RedUtil from "../util";
import RedActions from "../actions";

type RedMoreBlocky = Red.RawBlock | Red.RawParen | Red.RawString | Red.RawVector;

function isMoreBlocky(value: Red.AnyType): value is RedMoreBlocky {
	return value instanceof Red.RawBlock || value instanceof Red.RawParen
		|| value instanceof Red.RawString || value instanceof Red.RawVector;
}


/* Native actions */

export function $evalPath(
	ctx:     Red.Context,
	series:  Red.RawSeries,
	value:   Red.AnyType,
	_isCase: boolean
): Red.AnyType {
	return RedActions.$$pick(ctx, series, value as any); // TODO: stop being lazy
}

export function $setPath(
	ctx:      Red.Context,
	series:   Red.RawSeries,
	value:    Red.AnyType,
	newValue: Red.AnyType,
	_isCase:  boolean
): Red.AnyType {
	return RedActions.$$poke(ctx, series, value as any, newValue); // TODO: stop being lazy
}


/* Property reading actions */

export function $$head_q(
	_ctx:   Red.Context,
	series: Red.RawSeries
): Red.RawLogic {
	return Red.RawLogic.from(series.index == 1);
}

export function $$tail_q(
	ctx:    Red.Context,
	series: Red.RawSeries
): Red.RawLogic {
	return Red.RawLogic.from(series.index - 1 == $$head(ctx, series).length);
}

export function $$index_q(
	_ctx:   Red.Context,
	series: Red.RawSeries
): Red.RawInteger {
	return new Red.RawInteger(series.index);
}

export function $$length_q(
	_ctx:   Red.Context,
	series: Red.RawSeries
): Red.RawInteger {
	return new Red.RawInteger(series.length);
}

// Navigation

export function $$at(
	_ctx:   Red.Context,
	series: Red.RawSeries,
	index:  number
): Red.RawSeries {
	const _ = RedUtil.clone(series); // FIX: stop copying the series
	_.index = index < 1 ? 1 : index;
	return _;
}

export function $$back(
	_ctx:   Red.Context,
	series: Red.RawSeries
): Red.RawSeries {
	const _ = RedUtil.clone(series); // FIX: stop copying the series
	if(_.index > 1) _.index--;
	return _;
}

export function $$next(
	ctx:    Red.Context,
	series: Red.RawSeries
): Red.RawSeries {
	const _ = RedUtil.clone(series); // FIX: stop copying the series
	if(_.index-1 <= $$head(ctx, _).length) _.index++;
	return _;
}

export function $$skip(
	_ctx:   Red.Context,
	series: Red.RawSeries,
	index:  number
): Red.RawSeries {
	const _ = RedUtil.clone(series); // FIX: stop copying the series
	_.index += index;
	return _;
}

export function $$head(
	_ctx:   Red.Context,
	series: Red.RawSeries
): Red.RawSeries {
	const _ = RedUtil.clone(series); // FIX: stop copying the series
	_.index = 1;
	return _;
}

export function $$tail(
	ctx:    Red.Context,
	series: Red.RawSeries
): Red.RawSeries {
	const _ = RedUtil.clone(series); // FIX: stop copying the series
	_.index = $$head(ctx, _).length + 1;
	return _;
}

// Reading

export function $$pick(
	_ctx:  Red.Context,
	ser:   Red.RawSeries,
	index: Red.AnyType,
): Red.AnyType {
	if(!(index instanceof Red.RawInteger)) {
		throw new TypeError("error!");
	}
	
	if(index.value < 1) {
		return Red.RawNone.none;
	} else {
		if("pick" in ser) {
			if(ser instanceof Red.RawBinary) {
				return new Red.RawInteger(ser.pick(index.value));
			} else {
				return ser.pick(index.value);
			}
		} else {
			Red.todo();
		}
	}
}

/*
poke: make action! [[
		"Replaces the series value at a given index, and returns the new value"
		series	 [series! port! bitset!]
		index 	 [scalar! any-string! any-word! block! logic!]
		value 	 [any-type!]
		return:  [series! port! bitset!]
	]
	#get-definition ACT_POKE
]
*/
// wtf is this doing
export function $$poke(
	_ctx:  Red.Context,
	ser:   Red.RawSeries,
	index: Red.AnyType,
	value: Red.AnyType
): Red.AnyType {
	if(!(index instanceof Red.RawInteger)) {
		throw new TypeError("error!");
	}
	
	if(index.value < 1 || index.value > ser.length) {
		throw new RangeError("error!");
	} else {
		// change this lol
		if(ser instanceof Red.RawBlock || ser instanceof Red.RawParen) {
			if(ser.values[(ser.index - 1) + (index.value - 1)]) {
				ser.values[(ser.index - 1) + (index.value - 1)] = value;
				return value;
			} else {
				throw new RangeError("Value out of range!");
			}
		} else {
			Red.todo();
		}
	}
}

// Misc