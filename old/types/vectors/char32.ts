import {VectorOf} from "../typed-vector";

export default class Vector_Char32 extends VectorOf<"char!", 32> {
	constructor(values: number[] | Uint32Array) {
		super("char!", 32, values);
	}
	
	setNew(values: number[]): this {
		this.repr = new Uint32Array(values);
		return this;
	}
	
	copy(): Vector_Char32 {
		return new Vector_Char32([...this.repr]);
	}
	
	copyAs(fn: (v: Uint32Array) => Uint32Array): Vector_Char32 {
		return new Vector_Char32(fn(this.repr));
	}
	
	push(...values: number[]): number[] {
		this.repr = Uint32Array.of(...this.repr, ...values);
		return values;
	}
	
	unshift(...values: number[]): number[] {
		this.repr = Uint32Array.of(...values, ...this.repr);
		return values;
	}
	
	insert(index: number, ...values: number[]): number[] {
		if(index == 0) {
			return this.unshift(...values);
		} else if(index == this.repr.length - 1) {
			return this.push(...values);
		} else {
			this.repr = Uint32Array.of(...this.repr.slice(0, index), ...values, ...this.repr.slice(index));
			return values;
		}
	}
	
	remove(index: number, count: number): number[] {
		this.assertNotEmpty();
		if(count == 0) {
			return [];
		} else {
			const end = index + count;
			
			if(end >= this.repr.length) {
				throw new Error("Out of bounds!");
			} else if(end == this.repr.length - 1) {
				const res = [...this.repr.slice(index)];
				this.repr = this.repr.slice(0, index);
				return res;
			} else if(index == 0) {
				return this.shift(count);
			} else {
				const res = [...this.repr.slice(index, end)];
				this.repr = Uint32Array.of(...this.repr.slice(0, index), ...this.repr.slice(end));
				return res;
			}
		}
	}
	
	replace(index: number, count: number, ...values: number[]): number[] {
		const end = index + count;
		const newEnd = index + values.length;
		
		if(end >= this.repr.length) {
			throw new Error("Out of bounds!");
		} else if(end == newEnd && newEnd < this.repr.length) {
			this.repr.set(values, index);
		} else {
			const vals = [...this.repr];
			vals.splice(index, count, ...values);
			this.repr = new Uint32Array(vals);
		}
		
		return values;
	}
}