package util;

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

	@:overload(function(callback: (element: T) -> Bool, ?thisArg: Any): Int {})
	@:overload(function(callback: (element: T, index: Int) -> Bool, ?thisArg: Any): Int {})
	@:native("findIndex")
	function _findIndex(callback: (element: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Int;

	@:overload(function(callback: (element: T) -> Void, ?thisArg: Any): Void {})
	@:overload(function(callback: (element: T, index: Int) -> Void, ?thisArg: Any): Void {})
	@:native("forEach")
	function _forEach(callback: (element: T, index: Int, array: Array<T>) -> Void, ?thisArg: Any): Void;

	@:overload(function(callback: (element: T) -> Bool, ?thisArg: Any): Array<T> {})
	@:overload(function(callback: (element: T, index: Int) -> Bool, ?thisArg: Any): Array<T> {})
	@:native("filter")
	function _filter(callback: (element: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Array<T>;
}
#end


abstract ArrayTools<T>(Array<T>) from Array<T> to Array<T> {
#if (js && js_es >= 5)

	public inline static function every<T>(array: Array<T>, callback: (currentValue: T) -> Bool, ?thisArg: Any): Bool
		return inline (cast array : _ArrayProto<T>)._every(cast callback, thisArg);
	
	public inline static function everyi<T>(array: Array<T>, callback: (currentValue: T, index: Int) -> Bool, ?thisArg: Any): Bool
		return inline (cast array : _ArrayProto<T>)._every(cast callback, thisArg);
	
	public inline static function everyia<T>(array: Array<T>, callback: (currentValue: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Bool
		return inline (cast array : _ArrayProto<T>)._every(cast callback, thisArg);


	public inline static function some<T>(array: Array<T>, callback: (currentValue: T) -> Bool, ?thisArg: Any): Bool
		return inline (cast array : _ArrayProto<T>)._some(cast callback, thisArg);
	
	public inline static function somei<T>(array: Array<T>, callback: (currentValue: T, index: Int) -> Bool, ?thisArg: Any): Bool
		return inline (cast array : _ArrayProto<T>)._some(cast callback, thisArg);
	
	public inline static function someia<T>(array: Array<T>, callback: (currentValue: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Bool
		return inline (cast array : _ArrayProto<T>)._some(cast callback, thisArg);


	public inline static function fill<T>(array: Array<T>, value: T, ?start: Int, ?end: Int): Array<T>
		return inline (cast array : _ArrayProto<T>)._fill(value, start, end);


	public inline static function find<T>(array: Array<T>, callback: (element: T) -> Bool, ?thisArg: Any): Null<T>
		return inline (cast array : _ArrayProto<T>)._find(cast callback, thisArg);
	
	public inline static function findi<T>(array: Array<T>, callback: (element: T, index: Int) -> Bool, ?thisArg: Any): Null<T>
		return inline (cast array : _ArrayProto<T>)._find(cast callback, thisArg);
	
	public inline static function findia<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Null<T>
		return inline (cast array : _ArrayProto<T>)._find(cast callback, thisArg);


	public inline static function findIndex<T>(array: Array<T>, callback: (element: T) -> Bool, ?thisArg: Any): Int
		return inline (cast array : _ArrayProto<T>)._findIndex(cast callback, thisArg);
	
	public inline static function findIndexi<T>(array: Array<T>, callback: (element: T, index: Int) -> Bool, ?thisArg: Any): Int
		return inline (cast array : _ArrayProto<T>)._findIndex(cast callback, thisArg);
	
	public inline static function findIndexia<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Bool, ?thisArg: Any): Int
		return inline (cast array : _ArrayProto<T>)._findIndex(cast callback, thisArg);


	public inline static function forEach<T>(array: Array<T>, callback: (element: T) -> Void, ?thisArg: Any): Void
		(cast array : _ArrayProto<T>)._forEach(cast callback, thisArg);
	
	public inline static function forEachi<T>(array: Array<T>, callback: (element: T, index: Int) -> Void, ?thisArg: Any): Void
		(cast array : _ArrayProto<T>)._forEach(cast callback, thisArg);
	
	public inline static function forEachia<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Void, ?thisArg: Any): Void
		(cast array : _ArrayProto<T>)._forEach(cast callback, thisArg);

	public inline static function filter<T>(array: Array<T>, callback: (element: T) -> Bool): Array<T>
		return inline (cast array : _ArrayProto<T>)._filter(cast callback);

	public inline static function filteri<T>(array: Array<T>, callback: (element: T, index: Int) -> Bool): Array<T>
		return inline (cast array : _ArrayProto<T>)._filter(cast callback);

	public inline static function filteria<T>(array: Array<T>, callback: (element: T, index: Int, array: Array<T>) -> Bool): Array<T>
		return inline (cast array : _ArrayProto<T>)._filter(cast callback);

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
}