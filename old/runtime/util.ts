module RedUtil {
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
	
	export namespace Arrays {
		export function zip<T, U>(arr1: T[], arr2: U[]): [T, U][]
		export function zip<T, U, V>(arr1: T[], arr2: U[], mapping: (a1: T, a2: U) => V): V[]
		export function zip<T, U, V>(arr1: T[], arr2: U[], mapping?: (a1: T, a2: U) => V): V[] | [T, U][] {
			if(arr1.length != arr2.length) {
				throw new Error("Array lengths must be equal!");
			}
			
			if(mapping === undefined) {
				const out: [T, U][] = [];
				
				for(let i = 0; i < arr1.length; i++) {
					out.push([arr1[i], arr2[i]]);
				}
				
				return out;
			} else {
				const out: V[] = [];
				
				for(let i = 0; i < arr1.length; i++) {
					out.push(mapping(arr1[i], arr2[i]));
				}
				
				return out;
			}
		}
	}
}

export default RedUtil