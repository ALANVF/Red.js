import {VectorOf} from "../typed-vector";

export default class Vector_Integer16 extends VectorOf<"integer!", 16> {
	constructor(values: number[] | Int16Array) {
		super("integer!", 16, values);
	}
	
	setNew(values: number[]): this {
		this.repr = new Int16Array(values);
		return this;
	}
	
	copy(): Vector_Integer16 {
		return new Vector_Integer16([...this.repr]);
	}
	
	copyAs(fn: (v: Int16Array) => Int16Array): Vector_Integer16 {
		return new Vector_Integer16(fn(this.repr));
	}
	
	push(...values: number[]): number[] {
		this.repr = Int16Array.of(...this.repr, ...values);
		return values;
	}
	
	unshift(...values: number[]): number[] {
		this.repr = Int16Array.of(...values, ...this.repr);
		return values;
	}
	
	insert(index: number, ...values: number[]): number[] {
		if(index == 0) {
			return this.unshift(...values);
		} else if(index == this.repr.length - 1) {
			return this.push(...values);
		} else {
			this.repr = Int16Array.of(...this.repr.slice(0, index), ...values, ...this.repr.slice(index));
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
				this.repr = Int16Array.of(...this.repr.slice(0, index), ...this.repr.slice(end));
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
			this.repr = new Int16Array(vals);
		}
		
		return values;
	}
}