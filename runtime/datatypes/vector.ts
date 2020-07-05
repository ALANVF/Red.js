import * as Red from "../../red-types";
import RedActions from "../actions";
import {Vector, vector} from "../../types/typed-vector";

function isIntegerArray(array: Red.AnyType[]): array is Red.RawInteger[] {
	return array.every(v => v instanceof Red.RawInteger);
}

function isFloatArray(array: Red.AnyType[]): array is Red.RawFloat[] {
	return array.every(v => v instanceof Red.RawFloat);
}

function isPercentArray(array: Red.AnyType[]): array is Red.RawPercent[] {
	return array.every(v => v instanceof Red.RawPercent);
}

function isCharArray(array: Red.AnyType[]): array is Red.RawChar[] {
	return array.every(v => v instanceof Red.RawChar);
}

function isDefaultSize(vector: Vector) {
	if(vector.elemType == "integer!" || vector.elemType == "char!") {
		return vector.elemSize == 32;
	} else {
		return vector.elemSize == 64;
	}
}

function zeros(length: number): number[] {
	if(length == 0) {
		return [];
	} else {
		const res: number[] = [];
		
		res[length - 1] = 0;
		
		return res.fill(0);
	}
}

/* Actions */
export function $$make(
	_ctx:   Red.Context,
	_proto: Red.AnyType,
	spec:   Red.AnyType
): Red.RawVector {
	if(spec instanceof Red.RawInteger || spec instanceof Red.RawFloat) {
		const values = zeros(Math.floor(spec.value));
		
		return new Red.RawVector(vector("integer!", 32, values));
	} else if(spec instanceof Red.RawBlock) {
		const values = spec.current().values;
		
		// Yeah... this code is kinda bad (but it works, and that's what matters for now)
		if(values.length == 0) {
			return new Red.RawVector(vector("integer!", 32, []));
		} else if(isIntegerArray(values)) {
			return new Red.RawVector(vector("integer!", 32, values.map(v => v.value)));
		} else if(isFloatArray(values)) {
			return new Red.RawVector(vector("float!", 64, values.map(v => v.value)));
		} else if(isPercentArray(values)) {
			return new Red.RawVector(vector("percent!", 64, values.map(v => v.value)));
		} else if(isCharArray(values)) {
			return new Red.RawVector(vector("char!", 32, values.map(v => v.char)));
		} else if(values.length == 3) {
			const [_elem, _size, _elems] = values;
			
			if(_elem instanceof Red.RawWord && _size instanceof Red.RawInteger && _elems instanceof Red.RawBlock) {
				const elem = _elem.name.toLowerCase();
				const size = _size.value;
				const elems = _elems.current().values;
				
				if(elem == "integer!" && (size == 8 || size == 16 || size == 32) && isIntegerArray(elems)) {
					return new Red.RawVector(vector("integer!", size, elems.map(v => v.value)));
				} else if(elem == "float!" && (size == 32 || size == 64) && isFloatArray(elems)) {
					return new Red.RawVector(vector("float!", size, elems.map(v => v.value)));
				} else if(elem == "percent!" && (size == 32 || size == 64) && isPercentArray(elems)) {
					return new Red.RawVector(vector("percent!", size, elems.map(v => v.value)));
				} else if(elem == "char!" && (size == 8 || size == 16 || size == 32) && isCharArray(elems)) {
					return new Red.RawVector(vector("char!", size, elems.map(v => v.char)));
				} else {
					throw new Error("Invalid spec for vector!");
				}
			} else if(_elem instanceof Red.RawWord && _size instanceof Red.RawInteger && _elems instanceof Red.RawInteger) {
				const elem = _elem.name.toLowerCase();
				const size = _size.value;
				const length = _elems.value;
				
				if(elem == "integer!" && (size == 8 || size == 16 || size == 32)) {
					return new Red.RawVector(vector("integer!", size, zeros(length)));
				} else if(elem == "float!" && (size == 32 || size == 64)) {
					return new Red.RawVector(vector("float!", size, zeros(length)));
				} else if(elem == "percent!" && (size == 32 || size == 64)) {
					return new Red.RawVector(vector("percent!", size, zeros(length)));
				} else if(elem == "char!" && (size == 8 || size == 16 || size == 32)) {
					return new Red.RawVector(vector("char!", size, zeros(length)));
				} else {
					throw new Error("Invalid spec for vector!");
				}
			} else {
				throw new Error("Invalid spec for vector!");
			}
		} else if(values.length == 4) {
			const [_elem, _size, _length, _elems] = values;
			
			if(_elem instanceof Red.RawWord && _size instanceof Red.RawInteger
			&& _length instanceof Red.RawInteger && _elems instanceof Red.RawBlock) {
				const elem = _elem.name.toLowerCase();
				const size = _size.value;
				const length = _length.value;
				const elems = _elems.current().values;
				const numZeros = elems.length >= length ? 0 : length - elems.length;
				
				if(elem == "integer!" && (size == 8 || size == 16 || size == 32) && isIntegerArray(elems)) {
					return new Red.RawVector(vector("integer!", size, elems.map(v => v.value).concat(zeros(numZeros))));
				} else if(elem == "float!" && (size == 32 || size == 64) && isFloatArray(elems)) {
					return new Red.RawVector(vector("float!", size, elems.map(v => v.value).concat(zeros(numZeros))));
				} else if(elem == "percent!" && (size == 32 || size == 64) && isPercentArray(elems)) {
					return new Red.RawVector(vector("percent!", size, elems.map(v => v.value).concat(zeros(numZeros))));
				} else if(elem == "char!" && (size == 8 || size == 16 || size == 32) && isCharArray(elems)) {
					return new Red.RawVector(vector("char!", size, elems.map(v => v.char).concat(zeros(numZeros))));
				} else {
					throw new Error("Invalid spec for vector!");
				}
			} else {
				throw new Error("Invalid spec for vector!");
			}
		} else {
			throw new Error("Invalid spec for vector!");
		}
	} else {
		throw new TypeError(`Unexpected ${Red.typeName(spec)}`);
	}
}

export function $$form(
	_ctx:   Red.Context,
	vector: Red.RawVector,
	buffer: string[],
	_part?: number
): boolean {
	const blk = vector.values.repr.slice(vector.index-1);
	
	let mapping: (v: number) => string;
	
	switch(vector.values.elemType) {
		case "integer!": mapping = v => v.toFixed(0);                                break;
		case "float!":   mapping = v => v % 1 == 0 ? v.toFixed(1) : v.toString();    break;
		case "percent!": mapping = v => (v * 100).toString() + "%";                  break;
		case "char!":    mapping = v => new Red.RawChar(v).toJsChar();               break; // TODO: optimize this at some point
	}
	
	buffer.push(mapping(blk[0]));

	for(const val of blk.slice(1)) {
		buffer.push(" ");
		buffer.push(mapping(val));
	}

	return false;
}

export function $$mold(
	_ctx:    Red.Context,
	vector:  Red.RawVector,
	buffer:  string[],
	_indent: number,
	_: RedActions.MoldOptions = {}
): boolean {
	const blk = vector.values.repr.slice(vector.index-1);
	const isntDefault = !isDefaultSize(vector.values);
	
	buffer.push("make vector! [");
	
	if(isntDefault) {
		buffer.push(`${vector.values.elemType} ${vector.values.elemSize} [`);
	}
	
	if(blk.length != 0) {
		let mapping: (v: number) => string;
		
		switch(vector.values.elemType) {
			case "integer!": mapping = v => v.toFixed(0);                                break;
			case "float!":   mapping = v => v % 1 == 0 ? v.toFixed(1) : v.toString();    break;
			case "percent!": mapping = v => (v * 100).toString() + "%";                  break;
			case "char!":    mapping = v => '#"' + new Red.RawChar(v).toRedChar() + '"'; break; // TODO: optimize this at some point
		}
		
		buffer.push(mapping(blk[0]));
		
		for(const val of blk.slice(1)) {
			buffer.push(" ");
			buffer.push(mapping(val));
		}
		
		buffer.push("]");
	}
	
	if(isntDefault) {
		buffer.push("]");
	}

	return false;
}