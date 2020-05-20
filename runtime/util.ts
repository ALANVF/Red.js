module RedUtil {
	/*export function IN_TYPESET(
		ctx:   Red.Context,
		value: Red.AnyType,
		ts:    Red.RawTypeset
	): boolean {
		for(const t of ts.types) {
			if(t instanceof Red.RawWord) {
				const ty = RedNatives.$$get(ctx, t);

				if(ty instanceof Red.RawTypeset) {
					return IN_TYPESET(ctx, value, ty);
				} else {
					return value.constructor === ty;
				}
			} else {
				throw new Error("error!");
			}
		}
		return false;
	}*/
	
	export function make<T>(
		typeFn:  new(...args: any[]) => T,
		initObj: {[k in keyof T]?: k extends undefined ? any : T[k]}
	): T {
		let inst = new typeFn;
		
		for(const key in initObj) {
			inst[key] = initObj[key] as T[typeof key];
		}
		
		return inst;
	}

	export function clone<T extends object>(obj: T): T {
		const copy = Object.create(obj); //obj.constructor(); <-- doesn't work?
		
		for(const key in obj) {
			if(key in obj) {
				copy[key] = obj[key];
			}
		}
		
		return copy as T;
	}
}

export default RedUtil