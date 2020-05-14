import * as Red from "../red-types";
import RedNatives from "./natives";

module RedUtil {
	export function IN_TYPESET(
		ctx: Red.Context,
		value: Red.AnyType,
		ts: Red.RawTypeset
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
				throw Error("error!");
			}
		}
		return false;
	}
	
	export function make<T>(t: new(...args: any[]) => T, v: {[k in keyof T]?: k extends undefined ? any : T[k]}): T {
		let inst = new t;
		
		for(const key in v) {
			inst[key] = v[key] as T[typeof key];
		}
		
		return inst;
	}

	export function clone<T extends object>(obj: T): T {
		let copy = Object.create(obj); //obj.constructor(); <-- doesn't work?
		
		for(const key in obj) {
			if(key in obj) {
				copy[key] = obj[key];
			}
		}
		
		return copy as T;
	}
}

export default RedUtil