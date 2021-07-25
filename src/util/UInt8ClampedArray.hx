package util;

import js.lib.HaxeIterator;
import js.lib.ArrayBuffer;
import haxe.io.ArrayBufferView;

typedef UInt8ClampedArrayData = js.lib.Uint8ClampedArray;
private typedef Data = UInt8ClampedArrayData;

@:forwardStatics(BYTES_PER_ELEMENT, of)
@:forward(length, buffer, join, entries, keys, values, toString)
abstract UInt8ClampedArray(UInt8ClampedArrayData) to js.lib.ArrayBufferView {
	public overload extern inline function new() this = js.Syntax.construct(Data);
	public overload extern inline function new(length: Int) this = new Data(length);
	public overload extern inline function new(values: Array<Int>) this = new Data(values);
	public overload extern inline function new(values: js.lib.ArrayBufferView) this = new Data(values);
	public overload extern inline function new(iter: js.lib.Iterator<Int>) this = new Data(iter);
	public overload extern inline function new(value: {values: () -> js.lib.Iterator<Int>}) this = new Data(value);
	public overload extern inline function new(buffer: ArrayBuffer, ?byteOffset: Int, ?length: Int) this = new Data(buffer, byteOffset, length);
	
	public static overload extern inline function from(values: js.lib.Int8Array) return Data.from(values);
	public static overload extern inline function from(values: js.lib.Int8Array, fn: (v: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Int8Array, fn: (v: Int, i: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Uint8Array) return Data.from(values);
	public static overload extern inline function from(values: js.lib.Uint8Array, fn: (v: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Uint8Array, fn: (v: Int, i: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Uint8ClampedArray) return Data.from(values);
	public static overload extern inline function from(values: js.lib.Uint8ClampedArray, fn: (v: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Uint8ClampedArray, fn: (v: Int, i: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Int16Array) return Data.from(values);
	public static overload extern inline function from(values: js.lib.Int16Array, fn: (v: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Int16Array, fn: (v: Int, i: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Uint16Array) return Data.from(values);
	public static overload extern inline function from(values: js.lib.Uint16Array, fn: (v: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Uint16Array, fn: (v: Int, i: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Int32Array) return Data.from(values);
	public static overload extern inline function from(values: js.lib.Int32Array, fn: (v: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Int32Array, fn: (v: Int, i: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Uint32Array) return Data.from(values);
	public static overload extern inline function from(values: js.lib.Uint32Array, fn: (v: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Uint32Array, fn: (v: Int, i: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Float32Array) return Data.from(values);
	public static overload extern inline function from(values: js.lib.Float32Array, fn: (v: Float) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Float32Array, fn: (v: Float, i: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Float64Array) return Data.from(values);
	public static overload extern inline function from(values: js.lib.Float64Array, fn: (v: Float) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: js.lib.Float64Array, fn: (v: Float, i: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: UInt8ClampedArray) return Data.from(values.getData());
	public static overload extern inline function from(values: UInt8ClampedArray, fn: (v: Int) -> Int) return Data.from(values.getData(), fn);
	public static overload extern inline function from(values: UInt8ClampedArray, fn: (v: Int, i: Int) -> Int) return Data.from(values.getData(), fn);
	public static overload extern inline function from(values: Array<Int>) return Data.from(values);
	public static overload extern inline function from(values: Array<Int>, fn: (v: Int) -> Int) return Data.from(values, fn);
	public static overload extern inline function from(values: Array<Int>, fn: (v: Int, i: Int) -> Int) return Data.from(values, fn);
	
	
	@:arrayAccess public inline function get(index: Int) return this[index];
	@:arrayAccess public inline function set(index: Int, value: Int) return this[index] = value;
	
	public inline function copyWithin(target: Int, start: Int, ?end: Int) return fromData(this.copyWithin(target, start, end));
	
	public overload extern inline function every(fn: (v: Int) -> Bool) return this.every(fn);
	public overload extern inline function every(fn: (v: Int, i: Int) -> Bool) return this.every(fn);
	
	public inline function fill(value: Int, ?start: Int, ?end: Int) return fromData(this.fill(value, start, end));
	
	public overload extern inline function filter(fn: (v: Int) -> Bool) return fromData(this.filter(fn));
	public overload extern inline function filter(fn: (v: Int, i: Int) -> Bool) return fromData(this.filter(fn));
	
	public overload extern inline function find(fn: (v: Int) -> Bool) return this.find(fn);
	public overload extern inline function find(fn: (v: Int, i: Int) -> Bool) return this.find(fn);
	
	public overload extern inline function findIndex(fn: (v: Int) -> Bool) return this.findIndex(fn);
	public overload extern inline function findIndex(fn: (v: Int, i: Int) -> Bool) return this.findIndex(fn);
	
	public overload extern inline function forEach(fn: (v: Int) -> Void) this.forEach(fn);
	public overload extern inline function forEach(fn: (v: Int, i: Int) -> Void) this.forEach(fn);
	
	public inline function includes(searchElement: Int, ?fromIndex: Int) return this.includes(searchElement, fromIndex);
	
	public inline function indexOf(searchElement: Int, ?fromIndex: Int) return this.indexOf(searchElement, fromIndex);
	
	public inline function lastIndexOf(searchElement:Int, ?fromIndex:Int) return this.lastIndexOf(searchElement, fromIndex);
	
	public overload extern inline function map(fn: (v: Int) -> Int) return fromData(this.map(fn));
	public overload extern inline function map(fn: (v: Int, i: Int) -> Int) return fromData(this.map(fn));
	
	public overload extern inline function reduce<T>(fn: (prev: T, current: Int) -> T, ?initial: T) return this.reduce(fn, initial);
	public overload extern inline function reduce<T>(fn: (prev: T, current: Int, i: Int) -> T, ?initial: T) return this.reduce(fn, initial);
	
	public overload extern inline function reduceRight<T>(fn: (prev: T, current: Int) -> T, ?initial: T) return this.reduceRight(fn, initial);
	public overload extern inline function reduceRight<T>(fn: (prev: T, current: Int, i: Int) -> T, ?initial: T) return this.reduceRight(fn, initial);
	
	public inline function reverse() return fromData(this.reverse());
	
	public overload extern inline function setAll(values: js.lib.Int8Array, ?offset: Int) this.set(values, offset);
	public overload extern inline function setAll(values: js.lib.Uint8Array, ?offset: Int) this.set(values, offset);
	public overload extern inline function setAll(values: js.lib.Uint8ClampedArray, ?offset: Int) this.set(values, offset);
	public overload extern inline function setAll(values: js.lib.Int16Array, ?offset: Int) this.set(values, offset);
	public overload extern inline function setAll(values: js.lib.Uint16Array, ?offset: Int) this.set(values, offset);
	public overload extern inline function setAll(values: js.lib.Int32Array, ?offset: Int) this.set(values, offset);
	public overload extern inline function setAll(values: js.lib.Uint32Array, ?offset: Int) this.set(values, offset);
	public overload extern inline function setAll(values: js.lib.Float32Array, ?offset: Int) this.set(values, offset);
	public overload extern inline function setAll(values: js.lib.Float64Array, ?offset: Int) this.set(values, offset);
	public overload extern inline function setAll(values: UInt8ClampedArray, ?offset: Int) this.set(values.getData(), offset);
	public overload extern inline function setAll(values: Array<Int>, ?offset: Int) this.set(values, offset);
	
	public inline function slice(?start: Int, ?end: Int) return fromData(this.slice(start, end));
	
	public overload extern inline function some(fn: (v: Int) -> Bool) return this.some(fn);
	public overload extern inline function some(fn: (v: Int, i: Int) -> Bool) return this.some(fn);
	
	public inline function sort(?compareFn: (x: Int, y: Int) -> Int) return fromData(this.sort(compareFn));
	
	public inline function subarray(?begin: Int, ?end: Int) return fromData(this.subarray(begin, end));
	
	public inline function iterator() return new HaxeIterator(this.values());
	public inline function keyValueIterator() return new HaxeIterator(this.entries());

	public inline function getData() return this;
	
	public static inline function fromData(d: UInt8ClampedArrayData) return (cast d : UInt8ClampedArray);
}