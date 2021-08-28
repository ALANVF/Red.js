package util;

/*
#if (js && js_es >= 5)
@:native("Array.prototype")
private extern interface _ArrayProto<T> {
	@:overload(function(callback: (currentValue: T) -> Bool, ?thisArg: Any): Bool {})
	@:overload(function(callback: (currentValue: T, index: Int) -> Bool, ?thisArg: Any): Bool {})
	@:native("every")
	function _every(callback: (currentValue: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Bool;

	@:overload(function(callback: (currentValue: T) -> Bool, ?thisArg: Any): Bool {})
	@:overload(function(callback: (currentValue: T, index: Int) -> Bool, ?thisArg: Any): Bool {})
	@:native("some")
	function _some(callback: (currentValue: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Bool;

	@:native("fill")
	function _fill(value: T, ?start: Int, ?end: Int): Array<T>;

	@:overload(function(callback: (element: T) -> Bool, ?thisArg: Any): Null<T> {})
	@:overload(function(callback: (element: T, index: Int) -> Bool, ?thisArg: Any): Null<T> {})
	@:native("find")
	function _find(callback: (element: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Null<T>;

	@:overload(function(callback: (element: T) -> Bool): Int {})
	@:overload(function(callback: (element: T, index: Int) -> Bool): Int {})
	@:native("findIndex")
	function _findIndex(callback: (element: T, index: Int, array: Array<T>) -> Bool): Int;
	
	@:overload(function(callback: (element: T) -> Bool, thisArg: Any): Int {})
	@:overload(function(callback: (element: T, index: Int) -> Bool, thisArg: Any): Int {})
	@:native("findIndex")
	function _findIndex_(callback: (element: T, index: Int, array: Array<T>) -> Bool, thisArg: Any): Int;

	@:overload(function(callback: (element: T) -> Void, ?thisArg: Any): Void {})
	@:overload(function(callback: (element: T, index: Int) -> Void, ?thisArg: Any): Void {})
	@:native("forEach")
	function _forEach(callback: (element: T, index: Int, array: Array<T>) -> Void, ?thisArg: Any): Void;

	@:overload(function(callback: (element: T) -> Bool, ?thisArg: Any): Array<T> {})
	@:overload(function(callback: (element: T, index: Int) -> Bool, ?thisArg: Any): Array<T> {})
	@:native("filter")
	function _filter(callback: (element: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Array<T>;

	@:native("copyWithin")
	function _copyWithin(target: Int, ?start: Int, ?end: Int): Array<T>;
}
#end
*/

class ArrayTools {
#if (js && js_es >= 5)
	public static inline function ofLength<T>(c: Class<Array<T>>, length: Int): Array<T>
		return js.Syntax.construct(c, length);

	public static overload extern inline function every<T>(array: Array<T>, callback: (currentValue: T) -> Bool): Bool
		return (untyped array).every(callback);
	
	public static overload extern inline function everyi<T>(array: Array<T>, callback: (currentValue: T, index: Int) -> Bool): Bool
		return (untyped array).every(callback);
	
	public static overload extern inline function everyia<T>(array: Array<T>, callback: (currentValue: T, index: Int, array: Array<T>) -> Bool): Bool
		return (untyped array).every(callback);


	public static overload extern inline function some<T>(array: Array<T>, callback: (currentValue: T) -> Bool): Bool
		return (untyped array).some(callback);
	
	public static overload extern inline function somei<T>(array: Array<T>, callback: (currentValue: T, index: Int) -> Bool): Bool
		return (untyped array).some(callback);
	
	public static overload extern inline function someia<T>(array: Array<T>, callback: (currentValue: T, index: Int, array: Array<T>) -> Bool): Bool
		return (untyped array).some(callback);


	public static overload extern inline function fill<T>(array: Array<T>, value: T): Array<T>
		return (untyped array).fill(value);
	public static overload extern inline function fill<T>(array: Array<T>, value: T, start: Int): Array<T>
		return (untyped array).fill(value, start);
	public static overload extern inline function fill<T>(array: Array<T>, value: T, start: Int, end: Int): Array<T>
		return (untyped array).fill(value, start, end);


	public static overload extern inline function find<T>(array: Array<T>, callback: (element: T) -> Bool): Null<T>
		return (untyped array).find(callback);
	
	public static overload extern inline function findi<T>(array: Array<T>, callback: (element: T, index: Int) -> Bool): Null<T>
		return (untyped array).find(callback);
	
	public static overload extern inline function findia<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Bool): Null<T>
		return (untyped array).find(callback);


	public static overload extern inline function findIndex<T>(array: Array<T>, callback: (element: T) -> Bool): Int
		return (untyped array).findIndex(callback);
	
	public static overload extern inline function findIndexi<T>(array: Array<T>, callback: (element: T, index: Int) -> Bool): Int
		return (untyped array).findIndex(callback);
	
	public static overload extern inline function findIndexia<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Bool): Int
		return (untyped array).findIndex(callback);


	public static overload extern inline function forEach<T>(array: Array<T>, callback: (element: T) -> Void): Void
		(untyped array).forEach(callback);
	
	public static overload extern inline function forEachi<T>(array: Array<T>, callback: (element: T, index: Int) -> Void): Void
		(untyped array).forEach(callback);
	
	public static overload extern inline function forEachia<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Void): Void
		(untyped array).forEach(callback);

	public static inline function filter<T>(array: Array<T>, callback: (element: T) -> Bool): Array<T>
		return (untyped array).filter(callback);

	public static inline function filteri<T>(array: Array<T>, callback: (element: T, index: Int) -> Bool): Array<T>
		return (untyped array).filter(callback);

	public static inline function filteria<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Bool): Array<T>
		return (untyped array).filter(callback);


	public static overload extern inline function flatMap<T, U>(array: Array<T>, callback: (element: T) -> Array<U>): Array<U>
		return (untyped array).flatMap(callback);
	public static overload extern inline function flatMap<T, U>(array: Array<T>, callback: (element: T, index: Int) -> Array<U>): Array<U>
		return (untyped array).flatMap(callback);
	public static overload extern inline function flatMap<T, U>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Array<U>): Array<U>
		return (untyped array).flatMap(callback);

	
	public static overload extern inline function copyWithin<T>(array: Array<T>, target: Int): Array<T>
		return (untyped array).copyWithin(target);
	public static overload extern inline function copyWithin<T>(array: Array<T>, target: Int, start: Int): Array<T>
		return (untyped array).copyWithin(target, start);
	public static overload extern inline function copyWithin<T>(array: Array<T>, target: Int, start: Int, end: Int): Array<T>
		return (untyped array).copyWithin(target, start, end);

#else

	public static function every<T>(array: Array<T>, callback: (currentValue: T) -> Bool) {
		for(value in array)
			if(!callback(value))
				return false;
		return true;
	}
	
	public static function everyi<T>(array: Array<T>, callback: (currentValue: T, index: Int) -> Bool) {
		for(i => value in array)
			if(!callback(value, i))
				return false;
		return true;
	}

	public static function everyia<T>(array: Array<T>, callback: (currentValue: T, index: Int, array: Array<T>) -> Bool) {
		for(i => value in array)
			if(!callback(value, i, array))
				return false;
		return true;
	}


	public static function some<T>(array: Array<T>, callback: (currentValue: T) -> Bool) {
		for(value in array)
			if(callback(value))
				return true;
		return false;
	}
	
	public static function somei<T>(array: Array<T>, callback: (currentValue: T, index: Int) -> Bool) {
		for(i => value in array)
			if(callback(value, i))
				return true;
		return false;
	}
	
	public static function someia<T>(array: Array<T>, callback: (currentValue: T, index: Int, array: Array<T>) -> Bool) {
		for(i => value in array)
			if(callback(value, i, array))
				return true;
		return false;
	}


	public static function fill<T>(array: Array<T>, value: T, ?start: Int, ?end: Int) {
		final len = array.length;

		if(start == null) start = 1;
		if(end == null) end = len;

		final k = Std.int(if(start < 0) Math.max(len + start, 0) else Math.min(start, len));
		final finalValue = Std.int(if(end < 0) Math.max(len + end, 0) else Math.min(end, len));

		for(i in k...finalValue) {
			array[i] = value;
		}

		return array;
	}


	public static function find<T>(array: Array<T>, callback: (element: T) -> Bool): Null<T> {
		for(value in array)
			if(callback(value))
				return value;
		return null;
	}
	
	public static function findi<T>(array: Array<T>, callback: (element: T, index: Int) -> Bool): Null<T> {
		for(i => value in array)
			if(callback(value, i))
				return array[i];
		return null;
	}

	public static function findia<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Bool): Null<T> {
		for(i => value in array)
			if(callback(value, i, array))
				return array[i];
		return null;
	}


	public static function findIndex<T>(array: Array<T>, callback: (element: T) -> Bool) {
		for(i => value in array)
			if(callback(value))
				return i;
		return -1;
	}
	
	public static function findIndexi<T>(array: Array<T>, callback: (element: T, index: Int) -> Bool) {
		for(i => value in array)
			if(callback(value, i))
				return i;
		return -1;
	}

	public static function findIndexia<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Bool) {
		for(i => value in array)
			if(callback(value, i, array))
				return i;
		return -1;
	}


	public static function forEach<T>(array: Array<T>, callback: (element: T) -> Void) {
		for(value in array)
			callback(value);
	}
	
	public static function forEachi<T>(array: Array<T>, callback: (element: T, index: Int) -> Void) {
		for(i => value in array)
			callback(value, i);
	}

	public static function forEachia<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Void) {
		for(i => value in array)
			callback(value, i, array);
	}

	public static function filteri<T>(array: Array<T>, callback: (element: T, index: Int) -> Bool): Array<T> {
		return [for(i => value in array)
			if(callback(value, i))
				value];
	}

	public static function filteria<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Bool): Array<T> {
		return [for(i => value in array)
			if(callback(value, i, array))
				value];
	}
#end

	/*
		@:overload(function<T>(callback: (previousValue: T, currentValue: T) -> T, initialValue: T): T {})
		@:overload(function<T>(callback: (previousValue: T, currentValue: T, index: Int) -> T, initialValue: T): T {})
		@:overload(function(callback: (previousValue: T, currentValue: T) -> Int): T {})
		@:overload(function(callback: (previousValue: T, currentValue: T, index: Int) -> Int): T {})
		@:overload(function(callback: (previousValue: T, currentValue: T, index: Int, array: Array<T>) -> Int): T {})
		function reduce<T>(callback: (previousValue: T, currentValue: T, index: Int, array: Array<T>) -> T, initialValue: T): T;
	
		@:overload(function<T>(callback: (previousValue: T, currentValue: T) -> T, initialValue: T): T {})
		@:overload(function<T>(callback: (previousValue: T, currentValue: T, index: Int) -> T, initialValue: T): T {})
		@:overload(function(callback: (previousValue: T, currentValue: T) -> Int): T {})
		@:overload(function(callback: (previousValue: T, currentValue: T, index: Int) -> Int): T {})
		@:overload(function(callback: (previousValue: T, currentValue: T, index: Int, array: Array<T>) -> Int): T {})
		function reduceRight<T>(callback: (previousValue: T, currentValue: T, index: Int, array: Array<T>) -> T, initialValue: T): T;
	*/

	public static function equals<T>(a1: Array<T>, a2: Array<T>) {
		return everyi(a1, (v, i) -> v == a2[i]);
	}

	public static function zip<T, U, V>(a1: Array<T>, a2: Array<U>, callback: (e1: T, e2: U) -> V) {
		if(a1.length != a2.length) {
			throw "error!";
		}

		return [for(i => e1 in a1) callback(e1, a2[i])];
	}

	public static function findMap<T, U>(array: Array<T>, callback: (element: T) -> Null<U>) {
		for(value in array) {
			final found = callback(value);

			if(found != null) {
				return found;
			}
		}

		return null;
	}
}