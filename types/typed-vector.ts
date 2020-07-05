export type ElemType =
	| "integer!"
	| "float!"
	| "percent!"
	| "char!";

export type ElemSize =
	| 8
	| 16
	| 32
	| 64;

type Repr<T extends ElemType, S extends ElemSize> =
	T extends "integer!"
		? (
			S extends 8  ? Int8Array     :
			S extends 16 ? Int16Array    :
			S extends 32 ? Int32Array    :
			               never
		) :
	T extends "char!"
		? (
			S extends 8  ? Uint8Array     :
			S extends 16 ? Uint16Array    :
			S extends 32 ? Uint32Array    :
			               never
		)
		: (
			S extends 32 ? Float32Array :
			S extends 64 ? Float64Array :
			               never
		);

/*type _Int8Array = Pick<Int8Array, keyof Uint8Array>;
type _Int16Array = Pick<Int16Array, keyof Uint16Array>;
type _Int32Array = Pick<Int32Array, keyof Uint32Array>;
type _IntArray = Pick<Pick<_Int8Array, keyof _Int16Array>, keyof _Int32Array>;
type _FloatArray = Pick<Float32Array, keyof Float64Array>;
type TypedArray = Pick<_IntArray, keyof _FloatArray>;*/

type TA =
	| Int8Array | Uint8Array
	| Int16Array | Uint16Array
	| Int32Array | Uint32Array
	| Float32Array | Float64Array;

export type TypedArray = {
	[k in keyof TA]: (
		TA[k] extends (this: TA, ...args: unknown[]) => unknown
			? (
				ReturnType<TA[k]> extends TA
					? (this: ThisParameterType<TA[k]>, ...a: Parameters<TA[k]>) => TA
					: TA[k]
			)
			: TA[k]
	)
};

export abstract class VectorOf<T extends ElemType, S extends ElemSize> {
	repr: Repr<T, S>;
	
	constructor(
		public elemType: ElemType,
		public elemSize: ElemSize,
		       values:   number[] | TypedArray
	) {
		if(elemType == "integer!") {
			if(elemSize == 8) {
				this.repr = <Repr<T, S>>new Int8Array(values);
			} else if(elemSize == 16) {
				this.repr = <Repr<T, S>>new Int16Array(values);
			} else if(elemSize == 32) {
				this.repr = <Repr<T, S>>new Int32Array(values);
			} else {
				throw new Error(`Invalid size ${elemSize} for vector of ${elemType}`);
			}
		} else if(elemType == "char!") {
			if(elemSize == 8) {
				this.repr = <Repr<T, S>>new Uint8Array(values);
			} else if(elemSize == 16) {
				this.repr = <Repr<T, S>>new Uint16Array(values);
			} else if(elemSize == 32) {
				this.repr = <Repr<T, S>>new Uint32Array(values);
			} else {
				throw new Error(`Invalid size ${elemSize} for vector of ${elemType}`);
			}
		} else {
			if(elemSize == 32) {
				this.repr = <Repr<T, S>>new Float32Array(values);
			} else if(elemSize == 64) {
				this.repr = <Repr<T, S>>new Float64Array(values);
			} else {
				throw new Error(`Invalid size ${elemSize} for vector of ${elemType}`);
			}
		}
	}
	
	
	get length(): number {
		return this.repr.length;
	}
	
	assertNotEmpty(): void | never {
		if(this.repr.length == 0) {
			throw new Error("Vector cannot be empty!");
		}
	}
	
	setTo(values: number[]): this {
		if(values.length == this.repr.length) {
			this.repr.set(values);
			return this;
		} else {
			throw new Error("Length error!");
		}
	}
	
	abstract setNew(values: number[]): this;
	
	abstract copy(): VectorOf<T, S>;
	
	setAs(fn: (v: Repr<T, S>) => Repr<T, S>): this {
		this.repr = fn(this.repr);
		return this;
	}
	
	abstract copyAs(fn: (v: Repr<T, S>) => Repr<T, S>): VectorOf<T, S>;
	
	//abstract mapSet(fn: (v: number, i?: number) => number): this;
	
	abstract push(...values: number[]): number[];
	
	pop(): number;
	pop(count: number): number[];
	pop(count?: number): number | number[] {
		this.assertNotEmpty();
		if(count === undefined) {
			const res = this.repr[this.repr.length - 1];
			this.repr = <Repr<T, S>>this.repr.slice(0, -1);
			return res;
		} else {
			const res = [...this.repr.slice(-count)];
			this.repr = <Repr<T, S>>this.repr.slice(0, count - 1);
			return res;
		}
	}
	
	abstract unshift(...values: number[]): number[];
	
	shift(): number;
	shift(count: number): number[];
	shift(count?: number): number | number[] {
		this.assertNotEmpty();
		if(count === undefined) {
			const res = this.repr[0];
			this.repr = <Repr<T, S>>this.repr.slice(1);
			return res;
		} else {
			const res = this.repr.slice(0, count);
			this.repr = <Repr<T, S>>this.repr.slice(count);
			return [...res];
		}
	}
	
	abstract insert(index: number, ...values: number[]): number[];
	
	abstract remove(index: number, count: number): number[];
	
	abstract replace(index: number, count: number, ...values: number[]): number[];
	
	slice(begin: number, end?: number): VectorOf<T, S> {
		return this.copyAs(repr => <Repr<T, S>>repr.slice(begin, end));
	}
	
	get(index: number): number {
		return this.repr[index];
	}
	
	set(index: number, value: number): number {
		return this.repr[index] = value;
	}
	
	[Symbol.iterator](): IterableIterator<number> {
		return this.repr.values();
	}
}

import Vector_Integer8 from "./vectors/integer8";
import Vector_Integer16 from "./vectors/integer16";
import Vector_Integer32 from "./vectors/integer32";
import Vector_Char8 from "./vectors/char8";
import Vector_Char16 from "./vectors/char16";
import Vector_Char32 from "./vectors/char32";
import Vector_Float32 from "./vectors/float32";
import Vector_Float64 from "./vectors/float64";

export type Vector = VectorOf<ElemType, ElemSize>;

export function vector(elem: ElemType, size: ElemSize, values: number[]): Vector {
	switch(elem + size) {
		case "integer!8":  return new Vector_Integer8(values);
		case "integer!16": return new Vector_Integer16(values);
		case "integer!32": return new Vector_Integer32(values);
		case "char!8":     return new Vector_Char8(values);
		case "char!16":    return new Vector_Char16(values);
		case "char!32":    return new Vector_Char32(values);
		case "float!32":   return new Vector_Float32(values);
		case "float!64":   return new Vector_Float64(values);
		default:           throw new Error(`Invalid vector! spec \`[${elem} ${size} [${values.join(" ")}]]\`!`);
	}
}