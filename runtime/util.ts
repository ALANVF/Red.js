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
	
	export function readFile(path: string): string {
		let res = "";
		let hasRequire: boolean;
		
		try {
			require;
			hasRequire = true;
		} catch(_) {
			hasRequire = false;
		}
		
		if(hasRequire) {
			res = require("fs").readFileSync(path).toString();
		} else {
			if(global.fetch === undefined) {
				throw new Error("Internal error!");
			} else {
				fetch(path).then(data => {
					data.text().then(text => {
						res = text;
					}).catch(err => {
						throw err;
					});
				}).catch(err => {
					throw err;
				});
			}
		}
		
		return res;
	}
	
	export namespace Dates {
		export function getYearday(date: Date): number {
			const diff = +date - +new Date(date.getFullYear(), 0, 1);
			return (diff / 86400000) + 1;
		}
		
		export function weekToDate(year: number, week: number): Date {
			week -= 1;
			
			const date = new Date(year, 0, week * 7);
			const day = date.getDay();
			
			if(day != 1) {
				date.setFullYear(year, 0, (week * 7) + ((day < 4) ? 1 - day : (6 - day) + 2));
			}
			
			return date;
		}
	}
}

export default RedUtil