package util;

import haxe.ds.Option;

@:publicFields
class OptionTools {
	static inline function fromNull<T>(t: Enum<Option<T>>, value: Null<T>) {
		return if(value == null) {
			None;
		} else {
			Some((value : T));
		}
	}

	static inline function toNull<T>(opt: Option<T>) {
		return switch opt {
			case None: null;
			case Some(v): v;
		}
	}
	
	static inline function value<T>(opt: Option<T>) {
		return switch opt {
			case Some(v): v;
			case None: throw "Value was empty!";
		}
	}

	static inline function map<T, U>(opt: Option<T>, fn: T -> U) {
		return switch opt {
			case None: None;
			case Some(v): Some(fn(v));
		}
	}

	static inline function flatMap<T, U>(opt: Option<T>, fn: T -> Option<U>) {
		return switch opt {
			case None: None;
			case Some(v): fn(v);
		}
	}

	static inline function filter<T>(opt: Option<T>, fn: T -> Bool) {
		return switch opt {
			case Some(v) if(fn(v)): Some(v);
			case _: None;
		}
	}

	static inline function every<T>(opt: Option<T>, fn: T -> Bool) {
		return switch opt {
			case Some(v): fn(v);
			case _: false;
		}
	}
	
	static inline function forEach<T>(opt: Option<T>, fn: T -> Void): Void {
		switch opt {
			case Some(v): fn(v);
			case None:
		}
	}

	static inline function orElse<T, U: T, V: T>(opt: Option<U>, other: V) {
		return switch opt {
			case Some(v): v;
			case None: other;
		};
	}
	
	static inline function isNone<T>(opt: Option<T>) {
		return opt.getIndex() == 0;
	}
	
	static inline function isSome<T>(opt: Option<T>) {
		return opt.getIndex() == 1;
	}

	public static macro function extractMap<T>(value: ExprOf<Option<T>>, pattern, expr) {
		return macro {
			switch($value) {
				case Some($pattern): Some($expr);
				default: None;
			}
		}
	}

	public static macro function extractIter<T>(value: ExprOf<Option<T>>, pattern, expr) {
		return macro {
			switch($value) {
				case Some($pattern): $expr;
				default: $a{[]};
			}
		}
	}
}