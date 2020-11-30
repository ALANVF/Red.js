export class Ref<T> {
	constructor(public ref: T) {}
	
	copy(): Ref<T> {
		return new Ref(this.ref);
	}
	
	copyWith<U = T>(fn: (v: T) => U): Ref<U> {
		return new Ref(fn(this.ref));
	}
	
	do<U = T>(fn: (v: T) => U): U {
		return fn(this.ref);
	}
	
	set(fn: (v: T) => T): this {
		this.ref = fn(this.ref);
		
		return this;
	}
}

export class StringBuilder {
	constructor(public str: string = "") {}
	
	push(...strings: string[]): this {
		this.str += strings.join("");
		
		return this;
	}
	
	pop(count: number = 1): this {
		if(count > 0) {
			this.str = this.str.slice(0, -count);
		}
		
		return this;
	}
}