package util;

#if js
import haxe.ds.Map;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import haxe.ds.EnumValueMap;
import js.lib.Object;
import js.lib.Map as JsMap;

@:forward(has, clear, size)
abstract Dict<K, V>(JsMap<K, V>) {
	public overload extern inline function new() this = new JsMap();
	public overload extern inline function new(values: Any) this = new JsMap(values);
	
	public static macro function of(map) {
		switch map {
			case macro [$a{pairs}]:
				return macro new Dict(untyped [$a{
					pairs.map(p -> switch p {
						case macro $k => $v: macro untyped [$k, $v];
						default: throw "error!";
					})
				}]);
				
			default: throw "error!";
		}
	}

	@:op([])
	inline function get(key) {
		return this.get(key);
	}

	@:op([])
	inline function set(key, value) {
		this.set(key, value);
		return value;
	}

	public inline function remove(key) {
		return this.delete(key);
	}

	public inline function forEach(callback: (value: V, key: K) -> Void) {
		this.forEach(cast callback);
	}

	public inline function iterator() {
		return this.iterator();
	}

	public inline function keyValueIterator() {
		return this.keyValueIterator();
	}

	/*@:from
	static inline function fromIntMap<V>(map: IntMap<V>): Dict<Int, V> {
		final dict = new Dict();

		js.Syntax.code(
			"for(const key in {0}) {
				{1}.set(+key, {0}[key]);
			}",
			@:privateAccess map.h,
			dict
		);

		return dict;
	}*/

	@:from
	static inline function from_IntMap<K: Int, V>(map: Map<K, V>): Dict<K, V> {
		final dict = new Dict();

		js.Syntax.code(
			"for(const key in {0}) {
				{1}.set(+key, {0}[key]);
			}",
			@:privateAccess (map : IntMap<V>).h,
			dict
		);

		return dict;
	}

	/*@:from
	static inline function fromStringMap<V>(map: StringMap<V>): Dict<String, V> {
		return new Dict(Object.entries(@:privateAccess map.h));
	}*/

	@:from
	static inline function from_StringMap<K: String, V>(map: Map<K, V>): Dict<K, V> {
		return new Dict(Object.entries(@:privateAccess (map : StringMap<V>).h));
	}

	@:from
	static inline function fromObjectMap<K: {}, V>(map: Map<K, V>): Dict<K, V> {
		throw "Please don't use this. This is implemented so badly in Haxe that I don't even know where to start.";
	}

	/*@:from
	static function fromEnumValueMap<K: EnumValue, V>(map: EnumValueMap<K, V>): Dict<K, V> {
		final dict = new Dict();
		
		for(k => v in map) {
			dict[k] = v;
		}

		return dict;
	}*/

	@:from
	static function from_EnumValueMap<K: EnumValue, V>(map: Map<K, V>): Dict<K, V> {
		final dict = new Dict();
		
		for(k => v in map) {
			dict[k] = v;
		}

		return dict;
	}

	@:from
	static function fromAnyMap<K, V>(map: Map<K, V>): Dict<K, V> {
		return if(map is IntMap) {
			(untyped from_IntMap(untyped map) : Dict<K, V>);
		} else if(map is StringMap) {
			(untyped from_StringMap(untyped map) : Dict<K, V>);
		} else if(map is ObjectMap) {
			(untyped fromObjectMap(untyped map) : Dict<K, V>);
		} else if(map is EnumValueMap) {
			(untyped from_EnumValueMap(untyped map) : Dict<K, V>);
		} else {
			throw "???";
		};
	}

	@:from
	static inline function fromArray<T, K, V>(array: Array<T>): Dict<K, V> {
		return new Dict(array);
	}
}
#else
import haxe.ds.Map;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import haxe.ds.EnumValueMap;

@:forward(clear)
abstract Dict<K, V>(Map<K, V>) {
	public overload extern inline function new() {
		throw "Why am I in a macro";
	}
	
	public overload extern inline function new(values: Any) {
		throw "Why am I in a macro";
	}
	
	public static macro function of(map) {
		switch map {
			case macro [$a{pairs}]:
				return macro new Dict(untyped [$a{
					pairs.map(p -> switch p {
						case macro $k => $v: macro untyped [$k, $v];
						default: throw "error!";
					})
				}]);
				
			default: throw "error!";
		}
	}

	@:op([])
	function get(key): V {
		return this[key];
	}

	@:op([])
	inline function setKey(key, value): V {
		return this[key] = value;
	}

	public inline function remove(key): Bool {
		return this.remove(key);
	}

	public inline function has(key): Bool {
		return this.exists(key);
	}

	public inline function forEach(callback: (value: V, key: K) -> Void) {
		throw "Why am I in a macro";
	}

	public inline function iterator() {
		throw "Why am I in a macro";
	}

	public inline function keyValueIterator() {
		throw "Why am I in a macro";
	}

	@:from
	static inline function fromIntMap<V>(map: IntMap<V>): Dict<Int, V> {
		throw "Why am I in a macro";
	}

	@:from
	static inline function from_IntMap<K: Int, V>(map: Map<K, V>): Dict<K, V> {
		throw "Why am I in a macro";
	}

	@:from
	static inline function fromStringMap<V>(map: StringMap<V>): Dict<String, V> {
		throw "Why am I in a macro";
	}

	@:from
	static inline function from_StringMap<K: String, V>(map: Map<K, V>): Dict<K, V> {
		throw "Why am I in a macro";
	}

	@:from
	static inline function fromObjectMap<K: {}, V>(map: Map<K, V>): Dict<K, V> {
		throw "Why am I in a macro";
	}

	@:from
	static function fromEnumValueMap<K: EnumValue, V>(map: EnumValueMap<K, V>): Dict<K, V> {
		throw "Why am I in a macro";
	}

	@:from
	static function from_EnumValueMap<K: EnumValue, V>(map: Map<K, V>): Dict<K, V> {
		throw "Why am I in a macro";
	}

	@:from
	static function fromAnyMap<K, V>(map: Map<K, V>): Dict<K, V> {
		throw "Why am I in a macro";
	}

	@:from
	static inline function fromArray<T, K, V>(array: Array<T>): Dict<K, V> {
		throw "Why am I in a macro";
	}
}
#end