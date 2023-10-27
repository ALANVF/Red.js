package util;

import js.lib.HaxeIterator;
import js.lib.ArrayBuffer;
import haxe.io.ArrayBufferView;


@:publicFields
@:native("BigInt64Array")
extern class BigInt64Array /*implements js.lib.ArrayBufferView*/ implements ArrayAccess<BigInt> {
	@:overload(function(length: Int):Void {})
	@:overload(function(values: Array<Int>):Void {})
	@:overload(function(values: js.lib.ArrayBufferView):Void {})
	@:overload(function(iter: js.lib.Iterator<Int>):Void {})
	@:overload(function(value: {values: () -> js.lib.Iterator<Int>}):Void {})
	@:overload(function(buffer: ArrayBuffer, ?byteOffset: Int, ?length: Int):Void {})
	extern function new();

	@:overload(function(values: Array<BigInt>): BigInt64Array {})
	@:overload(function(values: Array<BigInt>, fn: (v: BigInt) -> BigInt): BigInt64Array {})
	static extern function from(values: Array<BigInt>, fn: (v: BigInt, i: Int) -> BigInt): BigInt64Array;

	static extern function of(...values: BigInt): BigInt64Array;
	
	extern function copyWithin(target: Int, start: Int, ?end: Int): BigInt64Array;
	
	@:overload(function(fn: (v: BigInt) -> Bool): BigInt64Array {})
	extern function every(fn: (v: BigInt, i: Int) -> Bool): BigInt64Array;
	
	extern function fill(value: BigInt, ?start: Int, ?end: Int): BigInt64Array;
	
	@:overload(function(fn: (v: BigInt) -> Bool): BigInt64Array {})
	extern function filter(fn: (v: BigInt, i: Int) -> Bool): BigInt64Array;
	
	@:overload(function(fn: (v: BigInt) -> Bool): BigInt64Array {})
	extern function find(fn: (v: BigInt, i: Int) -> Bool): Null<BigInt>;
	
	@:overload(function(fn: (v: BigInt) -> Bool): BigInt64Array {})
	extern function findIndex(fn: (v: BigInt, i: Int) -> Bool): Null<Int>;
	
	@:overload(function(fn: (v: BigInt) -> Void): Void {})
	extern function forEach(fn: (v: BigInt, i: Int) -> Void): Void;
	
	extern function includes(searchElement: Int, ?fromIndex: Int): Bool;
	
	extern function indexOf(searchElement: Int, ?fromIndex: Int): Int;
	
	extern function lastIndexOf(searchElement:Int, ?fromIndex:Int): Int;
	
	@:overload(function(fn: (v: BigInt) -> BigInt): BigInt64Array {})
	extern function map(fn: (v: BigInt, i: Int) -> BigInt): BigInt64Array;
	
	@:overload(function<T>(fn: (prev: T, current: BigInt) -> T, ?initial: T): T {})
	extern function reduce<T>(fn: (prev: T, current: BigInt, i: Int) -> T, ?initial: T): T;
	
	@:overload(function<T>(fn: (prev: T, current: BigInt) -> T, ?initial: T): T {})
	extern function reduceRight<T>(fn: (prev: T, current: BigInt, i: Int) -> T, ?initial: T): T;
	
	extern function reverse(): BigInt64Array;
	
	extern function set(values: Array<BigInt>, ?offset: Int): Void;
	
	extern function slice(?start: Int, ?end: Int): BigInt64Array;
	
	@:overload(function(fn: (v: BigInt) -> Bool): BigInt64Array {})
	extern function some(fn: (v: BigInt, i: Int) -> Bool): BigInt64Array;
	
	extern function sort(?compareFn: (x: BigInt, y: BigInt) -> Int): BigInt64Array;
	
	extern function subarray(?begin: Int, ?end: Int): BigInt64Array;
	
	inline function iterator(): Iterator<BigInt> return new HaxeIterator(untyped this.values());
	inline function keyValueIterator(): KeyValueIterator<Int, BigInt> return new HaxeIterator(untyped this.entries());
}