import Red from "./red";

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
	
	set(fn: (v: T) => T): Ref<T> {
		this.ref = fn(this.ref);
		return this;
	}
}